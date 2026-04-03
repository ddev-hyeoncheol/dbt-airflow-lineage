SELECT
    o.order_id,
    c.customer_name,
    c.region,
    p.product_name,
    p.category,
    o.status,
    o.quantity,
    o.unit_price,
    o.line_total,
    o.ordered_at
FROM staging.stg_orders o
JOIN staging.stg_customers c ON o.customer_id = c.customer_id
JOIN staging.stg_products p ON o.product_id = p.product_id
