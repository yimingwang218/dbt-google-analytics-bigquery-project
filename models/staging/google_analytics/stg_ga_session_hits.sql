with source as (

    select *
    from {{ source('google_analytics', 'ga_sessions') }}

),

renamed as (

    select
        concat(
            fullVisitorId,
            '-',
            cast(visitId as string),
            '-',
            date,
            '-',
            cast(hit.hitNumber as string)
        ) as hit_key,
        concat(fullVisitorId, '-', cast(visitId as string), '-', date) as session_key,
        hit.hitNumber as hit_number,
        hit.type as hit_type,
        hit.time as hit_time_milliseconds,
        hit.page.pagePath as page_path,
        hit.eCommerceAction.action_type as ecommerce_action_type,
        hit.eCommerceAction.step as ecommerce_action_step,
        hit.transaction.transactionId as transaction_id

    from source
    cross join unnest(hits) as hit

)

select *
from renamed
