
-- created users_clean
CREATE TABLE users_clean 
LIKE users_raw;

INSERT users_clean
SELECT *
FROM users_raw;

SELECT * FROM users_clean;
SELECT COUNT(*) FROM users_clean;

-- created ea_clean
CREATE TABLE ea_clean
LIKE ea_raw;

INSERT ea_clean
SELECT *
FROM ea_raw;

SELECT * FROM ea_clean;
SELECT COUNT(*) FROM ea_clean;

-- created subscriptions_clean
CREATE TABLE subscriptions_clean
LIKE subscriptions_raw;

INSERT subscriptions_clean
SELECT *
FROM subscriptions_raw;

SELECT * FROM subscriptions_clean;
SELECT COUNT(*) FROM subscriptions_clean;

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

