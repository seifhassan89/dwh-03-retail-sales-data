/* Questions: Which customer countries and product categories drive revenue? */
USE DataWarehouse;
GO
SELECT c.country, SUM(f.sales_amount) AS revenue
FROM gold.fact_sales f JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.country ORDER BY revenue DESC;
GO
SELECT p.category, SUM(f.sales_amount) AS revenue
FROM gold.fact_sales f JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.category ORDER BY revenue DESC;
GO
