/* Questions: How much revenue do we have? How many orders? */
USE DataWarehouse;
GO
SELECT COUNT(DISTINCT order_number) AS total_orders,
       SUM(sales_amount) AS total_revenue,
       SUM(quantity) AS units_sold
FROM gold.fact_sales;
GO
-- Compare revenue across years, using order date as the reporting date.
SELECT YEAR(order_date) AS sales_year, SUM(sales_amount) AS annual_revenue
FROM gold.fact_sales WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date) ORDER BY sales_year;
GO
