-- Finding: Single user (1957458976293878100) accounts for 99.5% of revenue
SELECT
  fullVisitorId,
  visitId,
  date,
  trafficSource.source,
  trafficSource.campaign,
  totals.transactions,
  ROUND(totals.totalTransactionRevenue/1000000, 2) AS revenue
FROM {{ source('google_analytics', 'ga_sessions') }}
WHERE _TABLE_SUFFIX BETWEEN '20170401' AND '20170430'
  AND channelGrouping = 'Display'
  AND totals.totalTransactionRevenue IS NOT NULL
ORDER BY revenue DESC;