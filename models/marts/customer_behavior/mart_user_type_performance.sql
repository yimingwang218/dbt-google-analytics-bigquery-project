with sessions as (

    select *
    from {{ ref('stg_ga_sessions') }}

),

user_type_performance as (

    select
        case
            when is_new_visitor then 'New User'
            else 'Returning User'
        end as user_type,
        count(*) as sessions,
        sum(transaction_count) as purchases,
        round(sum(transaction_revenue) / 1000000, 2) as revenue,
        round(sum(transaction_count) / nullif(count(*), 0) * 100, 2) as conversion_rate,
        round(sum(transaction_revenue) / 1000000 / nullif(sum(transaction_count), 0), 2) as avg_order_value

    from sessions
    group by 1

)

select *
from user_type_performance
