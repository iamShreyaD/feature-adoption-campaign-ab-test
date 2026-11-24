
CREATE FUNCTION parse_ts(s VARCHAR(50))
RETURNS DATETIME
DETERMINISTIC
RETURN CASE
  WHEN TRIM(s) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
    THEN STR_TO_DATE(TRIM(s), '%d/%m/%Y %H:%i:%s')
  WHEN TRIM(s) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}$'
    THEN STR_TO_DATE(TRIM(s), '%d/%m/%Y %H:%i')
  WHEN TRIM(s) REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'
    THEN STR_TO_DATE(TRIM(s), '%d/%m/%Y')
  WHEN TRIM(s) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$'
    THEN STR_TO_DATE(TRIM(s), '%Y-%m-%d %H:%i:%s')
  WHEN TRIM(s) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$'
    THEN STR_TO_DATE(TRIM(s), '%Y-%m-%d %H:%i')
  WHEN TRIM(s) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
    THEN STR_TO_DATE(TRIM(s), '%Y-%m-%d')
  ELSE NULL
END;

SELECT parse_ts('2026-05-20'), parse_ts('20/08/2026 14:30:00'), parse_ts('garbage');

USE fac;
SET SQL_SAFE_UPDATES = 0;

-- returning 0
SELECT COUNT(*) FROM users_clean WHERE prior_sessions_30_d NOT REGEXP '^[0-9]+$';
SELECT COUNT(*) FROM subscriptions_clean WHERE price NOT REGEXP '^[0-9]+([.][0-9]+)?$';
SELECT COUNT(*) FROM c_costs_clean WHERE impressions NOT REGEXP '^[0-9]+$' 
OR cost NOT REGEXP '^[0-9]+([.][0-9]+)?$';

--
SELECT DISTINCT email_opt_in FROM users_clean; -- True, False
SELECT DISTINCT exposure_flg FROM ea_clean; -- 1, 0
SELECT DISTINCT refunded_flag FROM subscriptions_clean; -- False, True

-- created users_clean
CREATE TABLE users_clean 
LIKE users_raw;

INSERT users_clean
SELECT *
FROM users_raw;

SELECT * FROM users_clean;
SELECT COUNT(*) FROM users_clean;

ALTER TABLE users_clean 
ADD COLUMN signup_ts DATETIME;
UPDATE users_clean
SET signup_ts = parse_ts(signup_date);
SELECT COUNT(*) AS unparsed FROM users_clean WHERE signup_ts IS NULL;

UPDATE users_clean SET country = 
CASE
	WHEN UPPER(TRIM(country)) IN ('INDIA', 'IN') THEN 'India'
    ELSE TRIM(country) 
END;

UPDATE users_clean SET
	city = COALESCE(NULLIF(TRIM(city), ''), 'Unknown'),
    platform = COALESCE(NULLIF(TRIM(platform), ''), 'Unknown'),
    age_group = COALESCE(NULLIF(TRIM(age_group), ''), 'Unknown'),
    user_type = LOWER(TRIM(user_type));
    
UPDATE users_clean SET email_opt_in = 
CASE WHEN LOWER(TRIM(email_opt_in)) IN ('true', '1', 'yes') THEN '1' ELSE '0' END;

ALTER TABLE users_clean
MODIFY prior_sessions_30_d INT NOT NULL,
MODIFY email_opt_in TINYINT(1) NOT NULL;

SELECT country, COUNT(*) 
FROM users_clean
GROUP BY country;

-- created ea_clean
CREATE TABLE ea_clean
LIKE ea_raw;

INSERT ea_clean
SELECT *
FROM ea_raw;

SELECT * FROM ea_clean;
SELECT COUNT(*) FROM ea_clean;

ALTER TABLE ea_clean
ADD COLUMN assignment_ts DATETIME;

UPDATE ea_clean
SET assignment_ts = parse_ts(assignment_timestamp);

SELECT COUNT(*) AS unparsed FROM ea_clean WHERE assignment_ts IS NULL;
ALTER TABLE ea_clean DROP COLUMN assignment_timestamp; 

UPDATE ea_clean SET variant = LOWER(TRIM(variant));
UPDATE ea_clean SET exposure_flg = 
CASE WHEN LOWER(TRIM(exposure_flg)) IN ('true','1', 'yes') THEN '1' ELSE '0' END;
ALTER TABLE ea_clean MODIFY exposure_flg TINYINT(1) NOT NULL;

-- remove users assigned to more than one variant
DELETE FROM ea_clean WHERE user_id IN (
	SELECT user_id FROM (
		SELECT user_id FROM ea_clean GROUP BY user_id HAVING COUNT(DISTINCT variant) > 1)x);

-- keep only the earliest row per user
DELETE FROM ea_clean WHERE assignment_id IN (
  SELECT assignment_id FROM (
    SELECT assignment_id,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY assignment_ts, assignment_id) AS rn
    FROM ea_clean) t
  WHERE rn > 1);
  
  SELECT variant, COUNT(*) FROM ea_clean GROUP BY variant;
  
-- created subscriptions_clean
CREATE TABLE subscriptions_clean
LIKE subscriptions_raw;

INSERT subscriptions_clean
SELECT *
FROM subscriptions_raw;

SELECT * FROM subscriptions_clean;
SELECT COUNT(*) FROM subscriptions_clean;

-- remove the 35 orphan subscriptions
SELECT COUNT(*) FROM subscriptions_clean WHERE user_id NOT IN (SELECT user_id FROM users_clean);
DELETE FROM subscriptions_clean WHERE user_id NOT IN (SELECT user_id FROM users_clean);

ALTER TABLE subscriptions_clean ADD COLUMN start_ts DATETIME;
UPDATE subscriptions_clean SET start_ts = parse_ts(start_date);
SELECT COUNT(*) AS unparsed FROM subscriptions_clean WHERE start_ts IS NULL;  -- must be 0
ALTER TABLE subscriptions_clean DROP COLUMN start_date;

UPDATE subscriptions_clean 
SET `plan` = LOWER(TRIM(`plan`)),
	currency = UPPER(TRIM(currency)), 
    status = LOWER(TRIM(status));
UPDATE subscriptions_clean SET refunded_flag =
  CASE WHEN LOWER(TRIM(refunded_flag)) IN ('true','1','yes') THEN '1' ELSE '0' END;

ALTER TABLE subscriptions_clean
  MODIFY price DECIMAL(14,2) NOT NULL,
  MODIFY refunded_flag TINYINT(1) NOT NULL,
  ADD INDEX idx_sub_user (user_id);

-- flag suspicious prices (wrong currency or ~10x values), but keep the rows
ALTER TABLE subscriptions_clean 
ADD COLUMN price_suspect TINYINT(1) NOT NULL DEFAULT 0;
UPDATE subscriptions_clean AS s
JOIN (SELECT `plan`, currency, AVG(price) AS avg_p
      FROM subscriptions_clean GROUP BY `plan`, currency) a
  ON a.`plan` = s.`plan` AND a.currency = s.currency
SET s.price_suspect = (s.price > 3 * a.avg_p OR s.price < a.avg_p / 3);

SELECT price_suspect, COUNT(*) FROM subscriptions_clean GROUP BY price_suspect;  -- total 6,965
SELECT `plan`, currency, MIN(price), MAX(price) FROM subscriptions_clean GROUP BY `plan`, currency;

-- created c_events_clean
CREATE TABLE c_events_clean
LIKE c_events_raw;

INSERT c_events_clean
SELECT *
FROM c_events_raw;

SELECT * FROM c_events_clean;
SELECT COUNT(*) FROM c_events_clean;

-- created c_costs_clean
CREATE TABLE c_costs_clean
LIKE c_costs_raw;

INSERT c_costs_clean
SELECT *
FROM c_costs_raw;

SELECT * FROM c_costs_clean;
SELECT COUNT(*) FROM c_costs_clean;

