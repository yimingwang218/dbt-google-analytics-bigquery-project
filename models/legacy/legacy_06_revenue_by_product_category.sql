-- Revenue by Product Category
SELECT
  p.v2ProductCategory AS category,
  ROUND(SUM(p.productRevenue)/1000000, 2) AS revenue,
  SUM(p.productQuantity) AS quantity_sold,
  COUNT(DISTINCT h.transaction.transactionId) AS transactions
FROM {{ source('google_analytics', 'ga_sessions') }},
UNNEST(hits) AS h,
UNNEST(h.product) AS p
WHERE h.eCommerceAction.action_type = '6'
  AND p.productRevenue IS NOT NULL
GROUP BY 1
ORDER BY revenue DESC