/*=============================================================================
  QUALITY CHECKS — return zero rows for every exception query.
  How to read: any returned row is a data quality issue to investigate.
=============================================================================*/
USE DataWarehouse;
GO
-- Duplicate customer IDs would multiply sales after a dimension join.
SELECT cst_id, COUNT(*) AS duplicate_count
FROM silver.crm_cust_info GROUP BY cst_id HAVING COUNT(*) > 1;
-- Duplicate product business keys would multiply sales after a dimension join.
SELECT prd_key, COUNT(*) AS duplicate_count
FROM silver.crm_prd_info GROUP BY prd_key HAVING COUNT(*) > 1;
-- Orders missing a dimension match should be investigated.
SELECT order_number, customer_key, product_key
FROM gold.fact_sales WHERE customer_key IS NULL OR product_key IS NULL;
-- Unexpected quantity / price values.
SELECT * FROM silver.crm_sales_details
WHERE sls_quantity <= 0 OR sls_order_dt IS NULL OR sls_sales IS NULL;
GO
