# Linux Cluster Monitoring Agent

## Introduction
The Linux Cluster Monitoring Agent project is designed to collect, store, and analyze hardware and system usage metrics across multiple Linux hosts. It automates the monitoring process using Bash scripts, a PostgreSQL database, and Docker for containerized deployment.
This project demonstrates key skills in Linux administration, shell scripting, SQL database design, and DevOps automation, providing a foundation for scalable infrastructure monitoring and data-driven performance analysis.

## Quick Start
```bash
# 1. Start a PostgreSQL instance using Docker
# This script creates (if needed) and starts a PostgreSQL container named 'jrvs-psql'
./scripts/psql_docker.sh start

# 2. Create the database and tables
# Run the DDL script to create the host_info and host_usage tables
psql -h localhost -U postgres -d host_agent -f sql/ddl.sql

# 3. Insert hardware specifications data
# This script runs once per host to record static hardware info
./scripts/host_info.sh localhost 5432 host_agent postgres your_password

# 4. Insert real-time hardware usage data
# This script collects CPU and memory usage metrics and inserts them into the database
./scripts/host_usage.sh localhost 5432 host_agent postgres your_password

# 5. Schedule automatic data collection with crontab
# Open crontab in edit mode
crontab -e
# Add the following line to run host_usage.sh every minute
* * * * * bash ~/scripts/host_usage.sh localhost 5432 host_agent postgres your_password > /tmp/host_usage.log 2>&1

```

## Implementation
This project collects system information and usage data from Linux hosts and stores it in a central PostgreSQL database that runs in a Docker container. The solution is built with Bash scripts and SQL, making it simple to deploy and maintain.

#### 1. Overview
- `host_info.sh` gathers static hardware details such as CPU, memory, and disk.
- `host_usage.sh` gathers live metrics such as CPU idle time, memory free, and disk space.
- A PostgreSQL database (inside a Docker container) stores all collected data in two tables: `host_info` and `host_usage`.
- `crontab` runs `host_usage.sh` automatically every minute to update metrics continuously.

#### 2. Setup Process
1. Start PostgreSQL using `psql_docker.sh` (creates or starts the container if needed).
2. Create database tables with `sql/ddl.sql`.
3. Run `host_info.sh` once per host to record its hardware specs.
4. Run `host_usage.sh` manually to test data insertion, then schedule it with `crontab` for continuous monitoring.

#### 3. Data Flow
1. Bash scripts use standard Linux commands (`lscpu`, `vmstat`, `df`, `free`) to collect data.
2. Scripts format the values and send SQL insert commands using `psql`.
3. Each insert is timestamped to allow trend analysis over time.

#### 4. Scripts Description
| Script | Purpose | Example Usage |
|---------|----------|----------------|
| `scripts/psql_docker.sh` | Manages the PostgreSQL Docker container (create, start, stop). | `./scripts/psql_docker.sh start` |
| `scripts/host_info.sh` | Collects and inserts static hardware information. | `./scripts/host_info.sh localhost 5432 host_agent postgres password` |
| `scripts/host_usage.sh` | Collects and inserts real-time usage metrics. | `./scripts/host_usage.sh localhost 5432 host_agent postgres password` |
| `sql/ddl.sql` | Creates database schema and tables. | `psql -h localhost -U postgres -d host_agent -f sql/ddl.sql` |
| `sql/queries.sql` | Contains example SQL queries for analysis. | `psql -h localhost -U postgres -d host_agent -f sql/queries.sql` |

#### 5. Database Modeling
- **`host_info`**: one record per host with static specifications.
- **`host_usage`**: multiple time-stamped records per host, linked to `host_info` through a foreign key.

#### 6. Scheduling
`crontab` is used to run `host_usage.sh` every minute for continuous monitoring.

```bash
* * * * * bash ~/scripts/host_usage.sh localhost 5432 host_agent postgres password >> /tmp/host_usage.log 2>&1
```

## Architecture and Design
![](/home/rocky/dev/jarvis_data_eng_IreneZheng/assets/Architecture.jpg)
This diagram shows how the Linux Cluster Monitoring System works. There are three Linux hosts that collect system information and usage data using Bash scripts. These scripts run automatically through crontab and send the data to a PostgreSQL database running in a Docker container.
The database stores all the collected information in two tables one for hardware details and one for usage data so everything can be viewed and analyzed in one place.

## Scripts
This project includes several Bash and SQL scripts that automate database setup, data collection, and analysis.  
Each script has a specific role in the monitoring system.
### 1. `psql_docker.sh`
**Purpose:**  
Manages the PostgreSQL database inside a Docker container  creates, starts, or stops the container as needed.

**Usage:**
```bash
# Create and start the container (if it doesn't exist)
./scripts/psql_docker.sh create

# Start the PostgreSQL container
./scripts/psql_docker.sh start

# Stop the PostgreSQL container
./scripts/psql_docker.sh stop
## Database Modeling
```
### 2. `host_info.sh`

This script collects static hardware information such as CPU details, memory, and disk size.  
It runs once per host to record system specifications in the database.

```bash
./scripts/host_info.sh localhost 5432 host_agent postgres your_password
```

The data is inserted into the `host_info` table.

---

### 3. `host_usage.sh`
This script collects real-time system usage data such as CPU idle time, available memory, and disk space.  
It runs every minute through `crontab` to monitor performance continuously.

```bash
./scripts/host_usage.sh localhost 5432 host_agent postgres your_password
```

The data is inserted into the `host_usage` table.

---

### 4. `crontab`
This setup automates the execution of `host_usage.sh` every minute to keep data updated in real time.

```bash
crontab -e
```

Add the following line:
```bash
* * * * * bash ~/scripts/host_usage.sh localhost 5432 host_agent postgres your_password >> /tmp/host_usage.log 2>&1
```

This ensures continuous monitoring without manual input.

---

### 5. `queries.sql`
This file contains SQL queries for data analysis and performance reporting.  
It helps answer questions such as:

- Which hosts have the highest CPU or memory usage?  
- Which machines are running low on available disk space?  
- What times of day show the highest system load?

```bash
psql -h localhost -U postgres -d host_agent -f sql/queries.sql
```

These queries help system administrators identify resource bottlenecks and optimize system performance.

## Database Modeling
The database contains two main tables: `host_info` and `host_usage`.  
Both tables are linked through a foreign key relationship based on the host ID.  
The `host_info` table stores static hardware information, while the `host_usage` table stores time-series performance data collected every minute.

---

### Table: `host_info`

| Column Name    | Data Type | Description |
|----------------|------------|--------------|
| id             | SERIAL (PK) | Unique ID for each host (primary key). |
| hostname       | VARCHAR     | Name of the host machine. |
| cpu_number     | INT         | Total number of CPU cores. |
| cpu_architecture | VARCHAR   | CPU architecture (e.g., x86_64). |
| cpu_model      | VARCHAR     | CPU model name. |
| cpu_mhz        | FLOAT       | CPU clock speed in MHz. |
| l2_cache       | INT         | L2 cache size (in KB). |
| total_mem      | INT         | Total memory available (in MB). |
| timestamp      | TIMESTAMP   | Time when the host was first added. |

---

### Table: `host_usage`

| Column Name    | Data Type | Description |
|----------------|------------|--------------|
| timestamp      | TIMESTAMP  | Time when the usage data was collected. |
| host_id        | INT (FK)   | Foreign key referencing `host_info(id)`. |
| memory_free    | INT        | Available memory (in MB) at the time of collection. |
| cpu_idle       | INT        | CPU idle percentage at the time of collection. |
| cpu_kernel     | INT        | CPU kernel usage percentage. |
| disk_io        | INT        | Number of disk I/O operations. |
| disk_available | INT        | Available disk space (in MB). |

---

**Relationship:**  
Each record in `host_usage` corresponds to a specific host in `host_info`.  
This one-to-many relationship allows multiple usage entries for a single host over time.
## Test

The testing process ensured that all Bash scripts and SQL DDL files worked correctly and produced the expected results.

### 1. Script Testing
Each Bash script was tested individually on the CentOS virtual machine.

- **psql_docker.sh**  
  - Verified container creation, start, and stop commands.  
  - Confirmed the PostgreSQL container was running using `docker ps`.  
  - Result: Container successfully created and connected to `host_agent` database.

- **host_info.sh**  
  - Executed manually to collect hardware information.  
  - Verified data insertion using:  
    ```bash
    psql -h localhost -U postgres -d host_agent -c "SELECT * FROM host_info;"
    ```  
  - Result: Hardware information inserted successfully for each host.

- **host_usage.sh**  
  - Ran the script manually to check system metrics collection.  
  - Verified that a new record was added each time the script ran.  
  - Result: Data inserted correctly with accurate timestamp and values.

### 2. Crontab Testing
Configured `crontab` to run `host_usage.sh` every minute.

- Checked logs in `/tmp/host_usage.log` to confirm successful execution.  
- Verified new rows appearing in `host_usage` table each minute.  
- Result: Automated data collection worked as expected.

### 3. Database Schema Testing
- Executed `sql/ddl.sql` to create the tables.  
- Used `\d` command in psql to confirm table structures matched the design.  
- Checked foreign key relationships between `host_info` and `host_usage`.  
- Result: Tables and constraints created successfully without errors.

### 4. Validation Queries
Ran `sql/queries.sql` to verify that stored data could be analyzed correctly.

Example:
```bash
psql -h localhost -U postgres -d host_agent -f sql/queries.sql
```
- Confirmed that the queries returned valid results, such as average CPU idle and memory usage by host.

- Result: Queries executed successfully and produced meaningful insights.

### Overall Result
- All scripts, DDL files, and automation processes functioned as expected.
- Data was collected, stored, and retrieved successfully from the PostgreSQL database.

## Deployment

The project was deployed using **Docker**, **GitHub**, and **crontab** for automation.

### 1. Docker Deployment
- The PostgreSQL database runs inside a **Docker container** managed by the `psql_docker.sh` script.  
- This approach ensures a consistent environment and isolates the database from the host system.  

**Commands used:**
```bash
# Create and start PostgreSQL container
./scripts/psql_docker.sh create
./scripts/psql_docker.sh start
```
- Data is stored in a named Docker volume, so it persists even if the container is removed.
- Verified deployment using:

```bash
docker ps
```
### 2. GitHub Repository

- All project files, including scripts, SQL files, and documentation, were version-controlled with Git.
- The repository was pushed to GitHub for collaboration, review, and backup.

Typical workflow:
```
git add .
git commit -m "Initial commit: add monitoring agent scripts and README"
git push origin main
```
- Pull requests were used for code review before merging changes to the main branch.

### 3. Crontab Automation

- The host_usage.sh script was scheduled using crontab to run automatically every minute.
- This enables continuous monitoring without manual intervention.

Setup:
```
crontab -e
```

Add this line:
```
* * * * * bash ~/scripts/host_usage.sh localhost 5432 host_agent postgres your_password >> /tmp/host_usage.log 2>&1
```

- Verified automation by checking /tmp/host_usage.log and confirming data was inserted into the database at one-minute intervals.
### Summary:

- Docker provided a portable PostgreSQL environment.
- GitHub ensured version control and project transparency.
- Crontab automated continuous system monitoring and data collection.

## Improvements
While the current version of the Linux Cluster Monitoring Agent meets the core requirements, there are several areas where it can be improved:

- **Handle hardware updates dynamically**  
  Currently, hardware information is inserted only once when the script `host_info.sh` is first executed.  
  A future enhancement could detect hardware configuration changes (e.g., memory or disk upgrades) and automatically update the database.

- **Add alerting and notification system**  
  Implement an alert mechanism (e.g., email, Slack, or webhook) to notify system administrators when CPU, memory, or disk usage exceeds certain thresholds.

- **Implement a visualization dashboard**  
  Integrate the PostgreSQL data with visualization tools such as **Grafana**, **Tableau**, or **Looker Studio** to provide real-time performance dashboards and trend analysis.

- **Add error logging and recovery**  
  Improve the Bash scripts to include detailed log files and automatic retries if a database connection or data insertion fails.

