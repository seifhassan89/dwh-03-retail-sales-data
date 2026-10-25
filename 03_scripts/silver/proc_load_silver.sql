/*=============================================================================
  SILVER LOAD — full-refresh cleaning and standardization
  Notes to myself:
  1. Choose one customer record per ID to avoid duplicate dimension joins.
  2. Clean names, gender, marital-status and country into consistent values.
  3. Reject malformed dates and non-positive sales quantities.
  4. Recalculate sales/price when the source contains inconsistent totals.
=============================================================================*/
USE DataWarehouse;
GO
CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        TRUNCATE TABLE silver.crm_sales_details;
        TRUNCATE TABLE silver.crm_prd_info;
        TRUNCATE TABLE silver.crm_cust_info;
        TRUNCATE TABLE silver.erp_cust_az12;
        TRUNCATE TABLE silver.erp_loc_a101;
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        -- CRM customer: use newest version of each source customer ID.
        WITH ranked AS
        (
            SELECT *, ROW_NUMBER() OVER
                (PARTITION BY cst_id ORDER BY cst_create_date DESC, cst_key DESC) AS rn
            FROM bronze.crm_cust_info WHERE cst_id IS NOT NULL
        )
        INSERT INTO silver.crm_cust_info
        SELECT cst_id, cst_key,
               NULLIF(TRIM(cst_firstname), ''), NULLIF(TRIM(cst_lastname), ''),
               CASE UPPER(TRIM(cst_marital_status)) WHEN 'S' THEN 'Single'
                    WHEN 'M' THEN 'Married' ELSE 'Unknown' END,
               CASE UPPER(TRIM(cst_gndr)) WHEN 'M' THEN 'Male'
                    WHEN 'F' THEN 'Female' ELSE 'Unknown' END,
               cst_create_date
        FROM ranked WHERE rn = 1;

        -- CRM products: split category code (prefix) from product business key.
        WITH ranked AS
        (
            SELECT *, ROW_NUMBER() OVER
                (PARTITION BY prd_key ORDER BY prd_start_dt DESC, prd_id DESC) AS rn
            FROM bronze.crm_prd_info WHERE prd_key IS NOT NULL
        )
        INSERT INTO silver.crm_prd_info
        SELECT prd_id, REPLACE(LEFT(prd_key, 5), '-', '_'),
               SUBSTRING(prd_key, 7, 50), TRIM(prd_nm),
               ISNULL(prd_cost, 0),
               CASE UPPER(TRIM(prd_line)) WHEN 'M' THEN 'Mountain'
                    WHEN 'R' THEN 'Road' WHEN 'S' THEN 'Other Sales' ELSE 'Unknown' END,
               prd_start_dt, prd_end_dt
        FROM ranked WHERE rn = 1;

        -- CRM sales: convert YYYYMMDD integer fields safely and normalize numbers.
        WITH cleaned AS
        (
            SELECT sls_ord_num, sls_prd_key, sls_cust_id,
                TRY_CONVERT(DATE, NULLIF(sls_order_dt, 0), 112) AS order_date,
                TRY_CONVERT(DATE, NULLIF(sls_ship_dt, 0), 112) AS ship_date,
                TRY_CONVERT(DATE, NULLIF(sls_due_dt, 0), 112) AS due_date,
                sls_sales, sls_quantity, sls_price
            FROM bronze.crm_sales_details
        )
        INSERT INTO silver.crm_sales_details
        SELECT sls_ord_num, sls_prd_key, sls_cust_id,
               order_date, ship_date, due_date,
               CASE WHEN sls_sales IS NULL OR sls_sales <= 0
                       OR sls_sales <> sls_quantity * sls_price
                    THEN sls_quantity * sls_price ELSE sls_sales END,
               sls_quantity,
               CASE WHEN sls_price IS NULL OR sls_price <= 0
                    THEN CASE WHEN sls_quantity > 0 THEN sls_sales / sls_quantity ELSE NULL END
                    ELSE sls_price END
        FROM cleaned
        WHERE order_date IS NOT NULL AND sls_quantity > 0;

        -- ERP customer: remove CRM prefix when present; standardize gender.
        WITH ranked AS
        (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY
                CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, 50) ELSE CID END
                ORDER BY BDATE DESC) AS rn
            FROM bronze.erp_cust_az12
        )
        INSERT INTO silver.erp_cust_az12
        SELECT CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, 50) ELSE CID END,
               CASE WHEN BDATE > CAST(GETDATE() AS DATE) THEN NULL ELSE BDATE END,
               CASE WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
                    WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
                    ELSE 'Unknown' END
        FROM ranked WHERE rn = 1;

        -- ERP location: standardize known country abbreviations.
        WITH ranked AS
        (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY CID ORDER BY CNTRY DESC) AS rn
            FROM bronze.erp_loc_a101
        )
        INSERT INTO silver.erp_loc_a101
        SELECT TRIM(CID), CASE UPPER(TRIM(CNTRY))
            WHEN 'US' THEN 'United States' WHEN 'USA' THEN 'United States'
            WHEN 'DE' THEN 'Germany' WHEN '' THEN 'Unknown'
            ELSE COALESCE(NULLIF(TRIM(CNTRY), ''), 'Unknown') END
        FROM ranked WHERE rn = 1;

        -- ERP category reference: de-duplicate before joining to products.
        WITH ranked AS
        (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY ID ORDER BY CAT, SUBCAT) AS rn
            FROM bronze.erp_px_cat_g1v2
        )
        INSERT INTO silver.erp_px_cat_g1v2
        SELECT TRIM(ID), TRIM(CAT), TRIM(SUBCAT), TRIM(MAINTENANCE)
        FROM ranked WHERE rn = 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
