# Runbook — learning environment

**Warning:** `init_database.sql` drops and recreates the `DataWarehouse` database. Use a disposable SQL Server instance.

1. Run `03_scripts/init_database.sql`.
2. Run `03_scripts/bronze/ddl_bronze.sql`.
3. Run `03_scripts/silver/ddl_silver.sql`.
4. Run `03_scripts/bronze/proc_load_bronze.sql` (review absolute CSV paths first).
5. Run `03_scripts/silver/proc_load_silver.sql`.
6. Run `03_scripts/gold/ddl_gold.sql`.
7. Execute `EXEC bronze.load_bronze; EXEC silver.load_silver;`.
8. Execute test files under `04_tests/`.
9. Explore queries in `03_scripts/analytics/`.

**CSV considerations:** The CSVs have headers; SQL Server service account needs read permission; `BULK INSERT` file paths refer to the **server** machine, not necessarily SSMS client's machine.
