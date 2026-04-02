-- Marquez DB
CREATE USER marquez WITH PASSWORD 'marquez';
CREATE DATABASE marquez OWNER marquez;

-- Warehouse DB (DBT)
CREATE USER dbt WITH PASSWORD 'dbt';
CREATE DATABASE warehouse OWNER dbt;
