with session_flags as (

    select *
    from {{ ref('int_ga_session_funnel_flags') }}

),

monthly_funnel_totals as (

    select
        date_trunc(session_date, month) as month,
        count(*) as total_sessions,
        countif(is_valid_session) as total_valid_sessions,
        countif(has_click = 1) as total_clicks,
        countif(has_product_view = 1) as total_product_views,
        countif(has_add_to_cart = 1) as total_add_to_cart,
        countif(has_checkout = 1) as total_checkout,
        countif(has_purchase = 1) as total_purchase

    from session_flags
    group by 1

),

monthly_funnel_totals_and_rates as (

    select
        month,
        total_sessions,
        total_valid_sessions,
        round(total_valid_sessions / nullif(total_sessions, 0) * 100, 2) as pct_valid_sessions,

        total_clicks,
        round(total_clicks / nullif(total_valid_sessions, 0) * 100, 2) as pct_clicks,

        total_product_views,
        round(total_product_views / nullif(total_valid_sessions, 0) * 100, 2) as pct_product_views,

        total_add_to_cart,
        round(total_add_to_cart / nullif(total_product_views, 0) * 100, 2) as pct_add_to_cart,

        total_checkout,
        round(total_checkout / nullif(total_add_to_cart, 0) * 100, 2) as pct_checkout,

        total_purchase,
        round(total_purchase / nullif(total_checkout, 0) * 100, 2) as pct_purchase,

        round(total_purchase / nullif(total_sessions, 0) * 100, 2) as overall_conversion_rate

    from monthly_funnel_totals

)

select *
from monthly_funnel_totals_and_rates
