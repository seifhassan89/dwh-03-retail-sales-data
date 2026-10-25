/*=============================================================================
  RECONCILIATION — Silver totals should equal Gold totals.
  Because Gold is a view, join cardinality errors are the main risk.
=============================================================================*/
USE DataWarehouse;
GO
DECLARE @SilverSales BIGINT = (SELECT SUM(CAST(sls_sales AS BIGINT)) FROM silver.crm_sales_details);
DECLARE @GoldSales BIGINT = (SELECT SUM(CAST(sales_amount AS BIGINT)) FROM gold.fact_sales);
SELECT @SilverSales AS silver_sales, @GoldSales AS gold_sales,
       COALESCE(@GoldSales,0) - COALESCE(@SilverSales,0) AS difference;
IF COALESCE(@SilverSales,0) <> COALESCE(@GoldSales,0)
    THROW 51000, 'Reconciliation failed: Gold sales do not match Silver.', 1;
GO
