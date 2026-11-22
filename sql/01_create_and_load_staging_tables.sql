
-- database created
CREATE DATABASE fac;

-- created table users_raw
CREATE TABLE users_raw (
user_id VARCHAR(50),
signup_date VARCHAR(50),
country VARCHAR(75),
city VARCHAR(50),
platform VARCHAR(50),
device_type VARCHAR(50),
acquisition_channel VARCHAR(50),
age_group VARCHAR(50),
user_type VARCHAR(50),
prior_sessions_30_d VARCHAR(50),
email_opt_in VARCHAR(50),
PRIMARY KEY(user_id)
);

LOAD DATA LOCAL INFILE 'C:/Users/shrey/Data/users.csv'
INTO TABLE users_raw
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT COUNT(*) FROM users_raw;

-- created table ea_raw
CREATE TABLE ea_raw (
assignment_id VARCHAR(50),
user_id VARCHAR(50),
variant VARCHAR(50),
assignment_timestamp VARCHAR(50),
exposure_flg VARCHAR(50),
PRIMARY KEY(assignment_id)
);

LOAD DATA LOCAL INFILE 'C:/Users/shrey/Data/experiment_assignments.csv'
INTO TABLE ea_raw
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT COUNT(*) FROM ea_raw;

-- created table subscriptions_raw
CREATE TABLE subscriptions_raw (
subscription_id VARCHAR(50),
user_id VARCHAR(50),
event_type VARCHAR(50),
event_timestamp VARCHAR(50),
`channel` VARCHAR(50),
PRIMARY KEY(subscription_id)
);

LOAD DATA LOCAL INFILE 'C:/Users/shrey/Data/subscriptions.csv'
INTO TABLE subscriptions_raw
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;
SELECT * FROM subscriptions_raw;

SELECT COUNT(*), COUNT(DISTINCT subscription_id) FROM subscriptions_raw;

-- created table c_events_raw
CREATE TABLE c_events_raw(
event_id VARCHAR(50), 
user_id VARCHAR(50), 
event_type VARCHAR(50), 
event_timestamp VARCHAR(50), 
`channel` VARCHAR(50)
);

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'C:/Users/shrey/Data/campaign_events.csv'
INTO TABLE c_events_raw
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT COUNT(*), COUNT(DISTINCT event_id) FROM c_events_raw;

-- created table c_costs_raw
CREATE TABLE c_costs_raw (
cost_id VARCHAR(50),
`date` VARCHAR(50),
variant VARCHAR(50),
`channel` VARCHAR(50),
impressions VARCHAR(50),
cost VARCHAR(50),
PRIMARY KEY(cost_id)
);

SELECT COUNT(*) FROM c_costs_raw;