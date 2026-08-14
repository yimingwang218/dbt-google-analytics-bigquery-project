with source as (

    select *
    from {{ source('google_analytics', 'ga_sessions') }}

),

renamed as (

    select
        concat(fullVisitorId, '-', cast(visitId as string), '-', date) as session_key,
        fullVisitorId as full_visitor_id,
        visitId as visit_id,
        parse_date('%Y%m%d', date) as session_date,
        timestamp_seconds(visitStartTime) as session_started_at,

        channelGrouping as channel_grouping,
        trafficSource.source as traffic_source,
        trafficSource.medium as traffic_medium,
        trafficSource.campaign as traffic_campaign,
        device.deviceCategory as device_category,

        totals.newVisits = 1 as is_new_visitor,
        totals.bounces as bounce_count,
        totals.pageviews as pageview_count,
        totals.transactions as transaction_count,
        totals.totalTransactionRevenue as transaction_revenue

    from source

)

select *
from renamed
