#!/usr/bin/env bash
# This script collects hardware specification data and then inserts the data into the psql instance.

# Setup arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Check the number of arguments
if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters"
  exit 1
fi

# Parse hardware specifications
hostname=$(hostname -f)
lscpu_out="$(lscpu)"
cpu_number=$(echo "$lscpu_out" | awk -F: '/^CPU\(s\):/ {print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | awk -F: '/^Architecture:/ {print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | awk -F: '/^Model name:/ {print $2}' | xargs | sed "s/'/''/g")
cpu_mhz=$(echo "$lscpu_out" | awk -F: '/^CPU MHz:/ {print $2}' | xargs)
if [ -z "$cpu_mhz" ]; then cpu_mhz=$(awk -F: '/cpu MHz/ {s+=$2;n++} END{if(n) printf "%.2f", s/n; else print 0}' /proc/cpuinfo); fi
l2_cache_kb=$(echo "$lscpu_out" | awk -F: '/^L2 cache:/ {gsub(/[^0-9]/,"",$2); print $2}' | xargs)
total_mem_mb=$(free -m | awk '/^Mem:/ {print $2}')
timestamp=$(date -u "+%F %T")

# Construct INSERT
insert_stmt="WITH ins AS (
  INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem, timestamp)
  SELECT '$hostname', $cpu_number, '$cpu_architecture', \$\$${cpu_model}\$\$, $cpu_mhz, $l2_cache_kb, $total_mem_mb, '$timestamp'
  WHERE NOT EXISTS (SELECT 1 FROM host_info WHERE hostname = '$hostname')
  RETURNING id
)
SELECT COALESCE((SELECT id FROM ins),(SELECT id FROM host_info WHERE hostname = '$hostname' LIMIT 1));"

# Execute INSERT
export PGPASSWORD="$psql_password"
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -t -A -c "$insert_stmt" >/dev/null || exit 1
exit 0
