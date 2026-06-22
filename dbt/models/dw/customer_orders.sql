{{ config(
    schema='dw',
    materialized='table'
) }}

with customers as (
    select
        customer_id,
        customer_name as name,
        email
    from {{ source('staging', 'customers') }}
),

orders as (
    select
        order_id,
        customer_id,
        order_date,
        status
    from {{ source('staging', 'orders') }}
),

order_items as (
    select
        order_id,
        price,
        quantity
    from {{ source('staging', 'order_items') }}
),

order_details as (
    -- 주문 번호(order_id)별 총 주문 금액과 상품 수량 집계
    select
        oi.order_id,
        o.customer_id,
        o.order_date,
        o.status as order_status,
        sum(oi.price * oi.quantity) as total_order_amount,
        sum(oi.quantity) as total_items_count
    from order_items oi
    join orders o on oi.order_id = o.order_id
    group by oi.order_id, o.customer_id, o.order_date, o.status
)

select
    od.order_id,
    c.customer_id,
    c.name as customer_name,
    c.email as customer_email,
    od.order_date,
    od.order_status,
    od.total_order_amount,
    od.total_items_count
from order_details od
left join customers c on od.customer_id = c.customer_id
