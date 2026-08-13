WITH session_flags AS (
  SELECT
    fullVisitorId,
    visitId,
    device.deviceCategory,
    totals.bounces,
    MAX(CASE WHEN h.eCommerceAction.action_type = '2' THEN 1 ELSE 0 END) AS has_product_view,
    MAX(CASE WHEN h.eCommerceAction.action_type = '3' THEN 1 ELSE 0 END) AS has_add_to_cart,
    MAX(CASE WHEN h.eCommerceAction.action_type = '5' THEN 1 ELSE 0 END) AS has_checkout,
    MAX(CASE WHEN h.eCommerceAction.action_type = '6' THEN 1 ELSE 0 END) AS has_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
  UNNEST(hits) AS h
  GROUP BY 1, 2, 3, 4
)
SELECT
  deviceCategory,
  COUNT(*) AS total_sessions,

  -- Top of funnel
  COUNTIF(bounces IS NULL) AS valid_sessions,
  ROUND(COUNTIF(bounces IS NULL) / NULLIF(COUNT(*), 0) * 100, 2) AS pct_valid_sessions,

  -- Product view
  COUNTIF(has_product_view = 1) AS product_views,
  ROUND(COUNTIF(has_product_view = 1) / NULLIF(COUNTIF(bounces IS NULL), 0) * 100, 2) AS pct_product_view,

  -- Add to cart
  COUNTIF(has_add_to_cart = 1) AS add_to_cart,
  ROUND(COUNTIF(has_add_to_cart = 1) / NULLIF(COUNTIF(has_product_view = 1), 0) * 100, 2) AS cart_rate,

  -- Checkout
  COUNTIF(has_checkout = 1) AS checkout,
  ROUND(COUNTIF(has_checkout = 1) / NULLIF(COUNTIF(has_add_to_cart = 1), 0) * 100, 2) AS pct_checkout,

  -- Purchase
  COUNTIF(has_purchase = 1) AS purchases,
  ROUND(COUNTIF(has_purchase = 1) / NULLIF(COUNTIF(has_checkout = 1), 0) * 100, 2) AS checkout_completion_rate,

  -- Overall
  ROUND(COUNTIF(has_purchase = 1) / NULLIF(COUNT(*), 0) * 100, 2) AS overall_conversion_rate

FROM session_flags
GROUP BY 1
ORDER BY total_sessions DESC