--source ctes

with customers as (
    select * from {{ ref('stg_jaffle_shop__customers') }}
),

orders as (
    select * from {{ ref('stg_jaffle_shop__orders') }}
),

base_payments as (
    select * from {{ ref('stg_stripe__payments') }}
),

payments as (
    select
        order_id,
        max(payment_date) as payment_finalized_date,
        sum(payment_amount) as total_amount_paid
    from base_payments
    where payment_status != 'fail'
    group by 1
),

paid_orders as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.order_status,
        payments.total_amount_paid,
        payments.payment_finalized_date,
        customers.givenname as first_name,
        customers.surname as last_name
    from orders
    left join payments on orders.order_id = payments.order_id
    left join customers on orders.customer_id = customers.customer_id

),

-- Final CTE

final as (

  select
    order_id,
    customer_id,
    order_date,
    order_status,
    total_amount_paid,
    payment_finalized_date,
    first_name,
    last_name,

    -- sales transaction sequence
    row_number() over (order by order_id) as transaction_seq,

    -- customer sales sequence
    row_number() over (partition by customer_id order by order_id) as customer_sales_seq,

    -- new vs returning customer
    case  
      when (
      rank() over (
      partition by customer_id
      order by order_date, order_id
      ) = 1
    ) then 'new'
    else 'return' end as nvsr,

    -- customer lifetime value
    sum(total_amount_paid) over (
      partition by customer_id
      order by order_date
      ) as customer_lifetime_value,

    -- first day of sale
    first_value(order_date) over (
      partition by customer_id
      order by order_date
      ) as fdos

    from paid_orders
		
)

-- Simple Select Statement

select * from final
order by order_id
