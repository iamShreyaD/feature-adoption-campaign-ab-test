
USE fac;

CREATE TABLE analysis_users AS
SELECT 
	a.user_id AS user_id, 
    a.variant AS variant, 
    a.assignment_ts AS assignment_ts,
    u.platform AS platform, 
    u.country AS country, 
    u.user_type AS user_type, 
    u.age_group AS age_group, 
    u.acquisition_channel AS acquisition_channel, 
    u.prior_sessions_30_d AS prior_sessions_30_d,
	CASE WHEN s.start_ts BETWEEN a.assignment_ts AND a.assignment_ts + INTERVAL 14 DAY
       THEN 1 ELSE 0 END AS converted_14d,
	CASE WHEN s.start_ts BETWEEN a.assignment_ts AND a.assignment_ts + INTERVAL 14 DAY
       THEN s.refunded_flag ELSE 0 END AS refunded_14d,
	EXISTS (
		SELECT 1 
        FROM c_events_clean AS e
		WHERE e.user_id = a.user_id AND e.event_type = 'unsubscribe'
            AND e.event_ts BETWEEN a.assignment_ts AND a.assignment_ts + INTERVAL 14 DAY) AS unsub_14d
FROM ea_clean AS a
JOIN users_clean AS u ON u.user_id = a.user_id
LEFT JOIN subscriptions_clean AS s ON s.user_id = a.user_id
WHERE a.assignment_ts <= '2026-08-14 23:59:59'
  AND a.user_id NOT IN (SELECT user_id FROM bot_users)
  AND (s.start_ts IS NULL OR s.start_ts >= a.assignment_ts);
  
SELECT * FROM analysis_users;
DESCRIBE analysis_users;
SELECT COUNT(*) FROM analysis_users;  -- 28266 records

SELECT 
	variant, 
    COUNT(*) AS n, 
    AVG(converted_14d) AS conv, 
    AVG(unsub_14d) AS unsub, 
    AVG(refunded_14d) AS refund
FROM analysis_users 
GROUP BY variant;

-- to export analysis_users
SELECT * FROM analysis_users;