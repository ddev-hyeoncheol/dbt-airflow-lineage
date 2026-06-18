{{ config(
    schema='dm',
    materialized='table'
) }}

select
    order_date,
    sum(total_order_amount) as daily_revenue,
    sum(total_items_count) as daily_items_sold,
    count(distinct order_id) as daily_orders_count
from {{ ref('customer_orders') }}    -- ⬅️ DW 모델(customer_orders)을 공식 참조하여 유기적 계보 확보
where order_status = 'completed'
group by order_date
