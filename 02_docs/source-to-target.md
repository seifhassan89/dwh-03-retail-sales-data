# Source-to-target mapping

| Source | Target | Main changes |
|---|---|---|
| CRM cust_info | Silver customer | Latest row per ID, TRIM, gender/marital codes |
| CRM prd_info | Silver product | Category ID extracted from key, product line mapping |
| CRM sales_details | Silver sales | Integer dates converted, quantity checked, totals normalized |
| ERP CUST_AZ12 | Silver customer ERP | Prefix cleanup, gender normalization, future birthdays discarded |
| ERP LOC_A101 | Silver location | Country abbreviations normalized |
| ERP PX_CAT_G1V2 | Silver categories | Trim and deduplicate |
| Silver CRM + ERP | Gold dimensions | Business-friendly descriptions and keys |
| Silver sales + Gold dimensions | Gold fact | Join customer/product keys for reporting |
