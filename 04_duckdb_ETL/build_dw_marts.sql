

-- Step 1: Datawarehouse - Create star schema tables
.read 01_create_tables.sql

-- Step 2: Datawarehouse - Load CSV files into tables
.read 02_load_schema_dw.sql 