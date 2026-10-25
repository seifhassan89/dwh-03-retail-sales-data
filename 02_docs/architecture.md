# Architecture and decisions

## Flow

`CRM + ERP CSV` → `Bronze raw tables` → `Silver cleaned tables` → `Gold star-schema views` → `Analytics queries`.

## Why three layers?

- **Bronze** preserves the source for inspection, reducing the temptation to overwrite raw evidence.
- **Silver** centralizes cleaning so analysts do not repeat transformations in reports.
- **Gold** exposes understandable customer, product and sales concepts with simple joins.

## Modeling choices

Gold dimensions and fact are **views** over Silver in this practice. The fact grain is **one source sales-detail row**, not one order. Date fields are plain date columns here rather than a date dimension. This mirrors a beginner warehouse learning sequence, not a production-grade slowly changing dimension implementation.

## Caution

`ROW_NUMBER` keys in Gold are computed view expressions, not persisted surrogate keys; they may be reassigned when source records change. Historical facts and stable long-lived keys require a different model.
