WITH session_flags AS (
  SELECT
     DATE_TRUNC(PARSE_DATE('%Y%m%d', date), MONTH) AS month,
    fullVisitorId,
    visitId,
    totals.bounces,
    totals.pageviews,
    MAX(CASE WHEN h.eCommerceAction.action_type = '1' THEN 1 ELSE 0 END) AS has_click,
    MAX(CASE WHEN h.eCommerceAction.action_type = '2' THEN 1 ELSE 0 END) AS has_product_view,
    MAX(CASE WHEN h.eCommerceAction.action_type = '3' THEN 1 ELSE 0 END) AS has_add_to_cart,
    MAX(CASE WHEN h.eCommerceAction.action_type = '5' THEN 1 ELSE 0 END) AS has_checkout,
    -- 三个checkout steps都不是一定会pop up 
    -- MAX(CASE WHEN h.eCommerceAction.action_type = '5' AND h.eCommerceAction.step = 1 THEN 1 ELSE 0 END) AS has_billing,
    -- MAX(CASE WHEN h.eCommerceAction.action_type = '5' AND h.eCommerceAction.step = 2 THEN 1 ELSE 0 END) AS has_payment,
    -- MAX(CASE WHEN h.eCommerceAction.action_type = '5' AND h.eCommerceAction.step = 3 THEN 1 ELSE 0 END) AS has_review,
    MAX(CASE WHEN h.eCommerceAction.action_type = '6' THEN 1 ELSE 0 END) AS has_purchase
  FROM {{ source('google_analytics', 'ga_sessions') }},
  UNNEST(hits) AS h
  GROUP BY month, fullVisitorId, visitId, totals.bounces, totals.pageviews
),

funnel_counts AS (
  SELECT
    month,
    COUNT(*) AS total_sessions,
    COUNTIF(bounces IS NULL) AS total_valid_sessions,
    COUNTIF(pageviews >= 1) AS total_has_pageviews,
    COUNTIF(has_click = 1) AS total_clicks,
    COUNTIF(has_product_view = 1) AS total_product_views,
    COUNTIF(has_add_to_cart = 1) AS total_add_to_cart,
    COUNTIF(has_checkout = 1) AS total_checkout,
    -- COUNTIF(has_billing = 1) AS total_billing,
    -- COUNTIF(has_payment = 1) AS total_payment,
    -- COUNTIF(has_review = 1) AS total_review,
    COUNTIF(has_purchase = 1) AS total_purchase
  FROM session_flags
  GROUP BY month
)
SELECT
  month,
  total_sessions,
  total_valid_sessions,
  ROUND(total_valid_sessions / NULLIF(total_sessions, 0) * 100, 2) AS pct_valid_sessions,

-- page views 好像是基于total sessions，bounces也算pageview
  -- total_has_pageviews, 
  -- ROUND(total_has_pageviews / NULLIF(total_valid_sessions, 0) * 100, 2) AS pct_has_pageviews,

  total_clicks,
  ROUND(total_clicks / NULLIF(total_valid_sessions, 0) * 100, 2) AS pct_clicks,

  total_product_views,
  ROUND(total_product_views / NULLIF(total_valid_sessions, 0) * 100, 2) AS pct_product_views,

  total_add_to_cart,
  ROUND(total_add_to_cart / NULLIF(total_product_views, 0) * 100, 2) AS pct_add_to_cart,

  total_checkout,
  ROUND(total_checkout / NULLIF(total_add_to_cart, 0) * 100, 2) AS pct_checkout,

  -- total_billing,
  -- ROUND(total_billing / NULLIF(total_checkout, 0) * 100, 2) AS pct_billing,

  -- total_payment,
  -- ROUND(total_payment / NULLIF(total_billing, 0) * 100, 2) AS pct_payment,

  -- total_review,
  -- ROUND(total_review / NULLIF(total_payment, 0) * 100, 2) AS pct_review,

  total_purchase,
  ROUND(total_purchase / NULLIF(total_checkout, 0) * 100, 2) AS pct_purchase,

  ROUND(total_purchase / NULLIF(total_sessions, 0) * 100, 2) AS overall_conversion_rate

FROM funnel_counts
ORDER BY month
