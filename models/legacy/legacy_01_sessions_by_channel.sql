-- Sessions and Revenue by Channel Over Time
SELECT
  FORMAT_DATE('%Y-%m', PARSE_DATE('%Y%m%d', date)) AS month,
  channelGrouping,
  COUNT(*) AS sessions,
  ROUND(SUM(totals.totalTransactionRevenue)/1000000, 2) AS revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
GROUP BY 1, 2
ORDER BY 1, 2