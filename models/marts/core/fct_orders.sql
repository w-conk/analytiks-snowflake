with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

final as (
    select
        orders.order_id as order_id,
        customers.customer_id as customer_id,
        payments.amount
    from orders
    left join customers using (customer_id)
    left join payments using (order_id)
)

select * from final

