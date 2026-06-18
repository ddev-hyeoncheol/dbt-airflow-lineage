-- Create schemas for the data pipeline layers
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS dw;
CREATE SCHEMA IF NOT EXISTS dm;

-- Grant all privileges on these schemas to the airflow user
GRANT ALL PRIVILEGES ON SCHEMA staging TO airflow;
GRANT ALL PRIVILEGES ON SCHEMA dw TO airflow;
GRANT ALL PRIVILEGES ON SCHEMA dm TO airflow;

-- Ensure default privileges are granted for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA staging GRANT ALL ON TABLES TO airflow;
ALTER DEFAULT PRIVILEGES IN SCHEMA dw GRANT ALL ON TABLES TO airflow;
ALTER DEFAULT PRIVILEGES IN SCHEMA dm GRANT ALL ON TABLES TO airflow;
