--  Revenue & Conversion Rate by New vs Old Users
SELECT
  CASE WHEN totals.newVisits = 1 THEN 'New User' ELSE 'Returning User' END AS user_type,
  COUNT(*) AS sessions,
  SUM(totals.transactions) AS purchases,
  ROUND(SUM(totals.totalTransactionRevenue)/1000000, 2) AS revenue,
  ROUND(SUM(totals.transactions) / NULLIF(COUNT(*), 0) * 100, 2) AS conversion_rate,
  ROUND(SUM(totals.totalTransactionRevenue)/1000000 / NULLIF(SUM(totals.transactions), 0), 2) AS avg_order_value
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
GROUP BY 1