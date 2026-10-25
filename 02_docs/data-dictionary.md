# Data dictionary — key output fields

| Object | Column | Meaning |
|---|---|---|
| `gold.dim_customers` | `customer_key` | Computed view row number (not persisted) |
| `gold.dim_customers` | `customer_id` | CRM customer identifier |
| `gold.dim_customers` | `country` | Standardized ERP location |
| `gold.dim_products` | `product_key` | Computed view row number (not persisted) |
| `gold.dim_products` | `product_number` | CRM product business key |
| `gold.dim_products` | `category` | ERP category label |
| `gold.fact_sales` | `order_number` | Source order number; not unique at sales-line grain |
| `gold.fact_sales` | `sales_amount` | Cleaned source sales measure |
| `gold.fact_sales` | `quantity` | Sales-line quantity |
| `gold.fact_sales` | `price` | Sales-line unit price |
