with session as (
    select * from {{ ref('stg_ga_sessions') }}

),

hits as (
    select * from {{ ref('stg_ga_session_hits') }}

),

session_flags as (

    select 
        session.session_key,
        session.session_date,
        session.channel_grouping,
        session.device_category,
        session.bounce_count,
        session.pageview_count,
        session.bounce_count is null as is_valid_session,
        MAX(CASE WHEN hits.ecommerce_action_type = '1' THEN 1 ELSE 0 END) AS has_click,
        MAX(CASE WHEN hits.ecommerce_action_type = '2' THEN 1 ELSE 0 END) AS has_product_view,
        MAX(CASE WHEN hits.ecommerce_action_type = '3' THEN 1 ELSE 0 END) AS has_add_to_cart,
        MAX(CASE WHEN hits.ecommerce_action_type = '5' THEN 1 ELSE 0 END) AS has_checkout,
        MAX(CASE WHEN hits.ecommerce_action_type = '6' THEN 1 ELSE 0 END) AS has_purchase
    from session 
    left join hits using (session_key)
        group by 1,2,3,4,5,6,7
    )

select * from session_flags