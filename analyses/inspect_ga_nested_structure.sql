select
    fullVisitorId as full_visitor_id,
    visitId as visit_id,
    date as session_date,

    to_json_string(trafficSource) as traffic_source_json,
    to_json_string(hits[safe_offset(0)]) as first_hit_json

from {{ source('google_analytics', 'ga_sessions') }}
where _TABLE_SUFFIX = '20170315'
  and array_length(hits) > 0
