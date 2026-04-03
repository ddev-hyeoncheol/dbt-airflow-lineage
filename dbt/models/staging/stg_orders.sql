SELECT
    o.id AS order_id,
    o.customer_id,
    o.status,
    o.ordered_at,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total
FROM public.orders o
JOIN public.order_items oi ON o.id = oi.order_id
