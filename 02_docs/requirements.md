# Business requirements

**Business problem:** Retail sales data is split between CRM and ERP exports, making analysis inconvenient.

**Goal:** Ingest the sources, clean the data and provide a simple dimensional model for sales reporting.

**Data sources:** CRM customer, product and sales CSVs; ERP customer, location and category CSVs.

**Outputs:** `gold.dim_customers`, `gold.dim_products`, `gold.fact_sales`.

**Business questions:** What is our revenue? Which products and customer countries contribute? How does sales change over time?

**Scope:** Latest dataset (full refresh), no SCD Type 2, no production deployment.

**Acceptance checks:** Stable source keys, reconciled total sales, valid order dates, clear exceptions for missing dimension joins.
