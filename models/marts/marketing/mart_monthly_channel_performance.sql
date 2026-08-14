with sessions as (

    select *
    from {{ ref('stg_ga_sessions') }}

),

monthly_channel_performance as (

    select
        date_trunc(session_date, month) as month,
        channel_grouping,
        count(*) as sessions,
        round(sum(transaction_revenue) / 1000000, 2) as revenue

    from sessions
    group by 1, 2

)

select *
from monthly_channel_performance
