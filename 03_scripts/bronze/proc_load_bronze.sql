/*=============================================================================
  BRONZE LOAD — full refresh from six local CSV files
  LEARNING: Bulk load keeps CSV values close to their original source form.
  SETUP: Change C:\retail-dwh\... paths to your own extracted location.
  WARNING: Each run truncates all Bronze tables before loading.
=============================================================================*/
USE DataWarehouse;
GO
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Step 1: Remove data from the previous practice run.
    TRUNCATE TABLE bronze.crm_sales_details;
    TRUNCATE TABLE bronze.crm_prd_info;
    TRUNCATE TABLE bronze.crm_cust_info;
    TRUNCATE TABLE bronze.erp_cust_az12;
    TRUNCATE TABLE bronze.erp_loc_a101;
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    -- Step 2: Reload CRM datasets.
    BULK INSERT bronze.crm_cust_info
    FROM 'C:\retail-dwh\01_datasets\source_crm\cust_info.csv'
    WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);

    BULK INSERT bronze.crm_prd_info
    FROM 'C:\retail-dwh\01_datasets\source_crm\prd_info.csv'
    WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);

    BULK INSERT bronze.crm_sales_details
    FROM 'C:\retail-dwh\01_datasets\source_crm\sales_details.csv'
    WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);

    -- Step 3: Reload ERP datasets.
    BULK INSERT bronze.erp_cust_az12
    FROM 'C:\retail-dwh\01_datasets\source_erp\CUST_AZ12.csv'
    WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);

    BULK INSERT bronze.erp_loc_a101
    FROM 'C:\retail-dwh\01_datasets\source_erp\LOC_A101.csv'
    WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);

    BULK INSERT bronze.erp_px_cat_g1v2
    FROM 'C:\retail-dwh\01_datasets\source_erp\PX_CAT_G1V2.csv'
    WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
END;
GO
