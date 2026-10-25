/*=============================================================================
  SCRIPT: Initialize learning database
  WHY: Start with three named layers in a clean, isolated database.
  WARNING: This intentionally deletes the existing DataWarehouse database.
=============================================================================*/
USE master;
GO
IF DB_ID(N'DataWarehouse') IS NOT NULL
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO
CREATE DATABASE DataWarehouse;
GO
USE DataWarehouse;
GO
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
