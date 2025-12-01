-- DDL script for host_agent project

CREATE TABLE IF NOT EXISTS public.host_info (
  id SERIAL PRIMARY KEY,
  hostname VARCHAR(255) NOT NULL UNIQUE,
  cpu_number SMALLINT NOT NULL,
  cpu_architecture VARCHAR(50) NOT NULL,
  cpu_model VARCHAR(255) NOT NULL,
  cpu_mhz FLOAT8 NOT NULL,
  l2_cache INTEGER NOT NULL,
  total_mem INTEGER NOT NULL,
  "timestamp" TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.host_usage (
  "timestamp" TIMESTAMP NOT NULL,
  host_id INT NOT NULL,
  memory_free INTEGER NOT NULL,
  cpu_idle SMALLINT NOT NULL,
  cpu_kernel SMALLINT NOT NULL,
  disk_io INTEGER NOT NULL,
  disk_available INTEGER NOT NULL,
  CONSTRAINT host_usage_pk PRIMARY KEY ("timestamp", host_id),
  CONSTRAINT host_usage_fk FOREIGN KEY (host_id)
      REFERENCES public.host_info(id)
      ON DELETE CASCADE
);
