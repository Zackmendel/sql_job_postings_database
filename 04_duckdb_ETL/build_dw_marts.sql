-- duckdb dw_marts.duckdb -c ".read build_dw_marts.sql"

-- Step 1: Datawarehouse - Create star schema tables
.read 01_create_tables.sql

-- Step 2: Datawarehouse - Load CSV files into tables
.read 02_load_schema_dw.sql 

-- Step 3: Mart - Create flat mart
.read 03_create_flat_mart.sql