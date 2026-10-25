/*=============================================================================
  GOLD — analytical views (latest snapshot, no SCD history)
  WHY: Keep business-friendly joins and names separate from ETL mechanics.
=============================================================================*/
USE DataWarehouse;
GO
CREATE OR ALTER VIEW gold.dim_customers AS
SELECT ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
       ci.cst_id AS customer_id, ci.cst_key AS customer_number,
       CONCAT(ci.cst_firstname, ' ', ci.cst_lastname) AS full_name,
       ci.cst_marital_status AS marital_status,
       COALESCE(NULLIF(ci.cst_gndr,'Unknown'), NULLIF(ca.GEN,'Unknown'), 'Unknown') AS gender,
       ca.BDATE AS birthdate, COALESCE(l.CNTRY,'Unknown') AS country
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca ON ci.cst_key = ca.CID
LEFT JOIN silver.erp_loc_a101 AS l ON ci.cst_key = l.CID;
GO
CREATE OR ALTER VIEW gold.dim_products AS
SELECT ROW_NUMBER() OVER (ORDER BY p.prd_id) AS product_key,
       p.prd_id AS product_id, p.prd_key AS product_number,
       p.prd_nm AS product_name, p.cat_id AS category_id,
       c.CAT AS category, c.SUBCAT AS subcategory,
       c.MAINTENANCE AS maintenance, p.prd_cost AS cost,
       p.prd_line AS product_line, p.prd_start_dt AS start_date
FROM silver.crm_prd_info AS p
LEFT JOIN silver.erp_px_cat_g1v2 AS c ON p.cat_id = c.ID;
GO
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT s.sls_ord_num AS order_number,
       p.product_key, c.customer_key,
       s.sls_order_dt AS order_date, s.sls_ship_dt AS shipping_date,
       s.sls_due_dt AS due_date, s.sls_sales AS sales_amount,
       s.sls_quantity AS quantity, s.sls_price AS price
FROM silver.crm_sales_details AS s
LEFT JOIN gold.dim_products AS p ON s.sls_prd_key = p.product_number
LEFT JOIN gold.dim_customers AS c ON s.sls_cust_id = c.customer_id;
GO
