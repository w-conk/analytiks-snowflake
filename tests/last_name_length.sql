with customers as (
    select * from {{ ref('stg_customers') }}
)
select 
    last_name
    from customers
where len(last_name) != 2