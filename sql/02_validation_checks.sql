
-- users_raw
-- checking duplicate IDs, missing city, age_group, platform, odd values in prior_sessions_30_d
SELECT COUNT(*) AS n, 
	COUNT(DISTINCT user_id) AS uniq,
	SUM(city IS NULL OR TRIM(city)='') AS missing_city,
	SUM(age_group IS NULL OR TRIM(age_group)='') AS missing_age_group,
	SUM(platform IS NULL OR TRIM(platform)='') AS missing_platform,
	MIN(prior_sessions_30_d) AS min_session, 
    MAX(prior_sessions_30_d) AS max_session
FROM users_raw;

SELECT country, COUNT(*) 
FROM users_raw
GROUP BY country;

-- ea_raw
-- checking duplicates, users in more than 1 variant, arm sizes (SRM), orphan users
SELECT variant,
	COUNT(*) AS total,
	COUNT(DISTINCT user_id) AS users
FROM ea_raw
GROUP BY variant;

SELECT COUNT(*) AS multi_variant_users 
FROM (
	SELECT user_id
    FROM ea_raw
    GROUP BY user_id
    HAVING COUNT(DISTINCT variant)>1
) AS t;

SELECT COUNT(*) AS orphans
FROM ea_raw AS a
LEFT JOIN users_raw AS u
USING(user_id)
WHERE u.user_id IS NULL;

-- subscriptions_raw
-- checking orphan users, repeat subscribers, price and currency outliers, status, refund values
SELECT COUNT(*), COUNT(DISTINCT subscription_id), COUNT(DISTINCT user_id)
FROM subscriptions_raw;

SELECT COUNT(*) AS orphans
FROM subscriptions_raw AS s
LEFT JOIN users_raw AS u 
USING(user_id)
WHERE u.user_id IS NULL;

SELECT plan, currency, COUNT(*), MIN(CAST(price AS DECIMAL(14, 2))) AS min_price, MAX(CAST(price AS DECIMAL(14, 2))) AS max_price
FROM subscriptions_raw
GROUP BY plan, currency;

SELECT `status`, refunded_flag, COUNT(*)
FROM subscriptions_raw
GROUP BY `status`, refunded_flag;

-- c_events_raw
-- checking duplicate event IDs, event types, orphan users, bot-like users
SELECT COUNT(*) AS total, COUNT(DISTINCT event_id) AS uniq
FROM c_events_raw;

SELECT event_id, COUNT(DISTINCT user_id)
FROM c_events_raw
GROUP BY event_id
HAVING COUNT(*)>1;

SELECT event_type, COUNT(*) AS total
FROM c_events_raw
GROUP BY event_type;

SELECT COUNT(*) AS orphans
FROM c_events_raw AS e
LEFT JOIN users_raw AS u 
USING(user_id)
WHERE u.user_id IS NULL;

-- c_costs_raw
-- checking total records, no duplicate keys, control cost, channel names
SELECT COUNT(*) FROM c_costs_raw;

SELECT `date`, variant, `channel`, COUNT(*)
FROM c_costs_raw
GROUP BY `date`, variant, `channel`
HAVING COUNT(*) > 1;

SELECT variant, `channel`, ROUND(SUM(cost), 2) AS total_cost, SUM(impressions) AS total_impressions
FROM c_costs_raw
GROUP BY variant, `channel`;