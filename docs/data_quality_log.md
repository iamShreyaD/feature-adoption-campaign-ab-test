# Data Quality Log and Cleaning Documentation

All work was done in MySQL (schema `fac`). Raw tables (`*_raw`) were loaded with every column as text so that no row was rejected. Each cleaned table (`*_clean`) was created as a copy of its raw table, then cleaned and typed in place by `sql/03_cleaning.sql`. Raw tables were left unchanged.

## 1. Issue log

| # | Table | Issue | How detected | Rows affected | Treatment |
|---|---|---|---|---|---|
| 1 | users | Missing city | Count of NULL or blank values | 3,000 (5%) | Set to `Unknown` |
| 2 | users | Missing age_group | Same | 1,800 (3%) | Set to `unknown` |
| 3 | users | Missing platform | Same | 1,200 (2%) | Set to `unknown` |
| 4 | users | Country aliases (`IN`, `India ` with trailing space) | `GROUP BY country` | 196 (94 + 102) | Standardised to `India` (India total 25,090) |
| 5 | assignments | Users assigned to more than one variant (contamination) | Users with `COUNT(DISTINCT variant) > 1` | 300 users | Removed all rows for these users |
| 6 | assignments | Repeated assignment rows (same user, same variant) | Total rows minus distinct users per variant | 600 rows | Kept the earliest row per user |
| 7 | all tables | Mixed timestamp formats (ISO and DD/MM/YYYY) | Inspection and failed parsing | Mixed | Parsed with `parse_ts()` |
| 8 | subscriptions | Orphan subscriptions (user_id not in users) | Left join to users | 35 | Deleted |
| 9 | subscriptions | Price and currency outliers (for example annual EUR prices up to 344,741 where typical prices are under 100, and monthly INR prices of about 5) | Numeric min and max by plan and currency | TODO: number flagged | Flagged in `price_suspect` (price more than 2x or less than half of the median for its plan and currency); kept for conversion counts, excluded from revenue |
| 10 | subscriptions | Subscription starts before the user's assignment | Compared `start_ts` with `assignment_ts` | About half (3,489 of 7,000 in the initial check) | Users excluded from the analysis population (pre-existing subscribers) |
| 11 | subscriptions / assignments | Outcome window censored: subscription data ends on the last assignment date (28 Aug) | Compared the latest dates in both tables | Users assigned after 14 Aug | Primary analysis restricted to users assigned by 14 Aug |
| 12 | events | Uppercase event types (for example `APP_OPEN`) | `GROUP BY event_type` | 1,200 | Lowercased |
| 13 | events | Events outside the experiment window (before 1 Aug or after 28 Aug) | Timestamp range check | 1,815 (0.3%) | Excluded from analysis, kept in table |
| 14 | events | Events before the user's signup | Join to users, `event_ts < signup_ts` | 94 | Excluded from analysis |
| 15 | events | Android `app_open` logging outage | Daily Android `app_open` counts | No events on 12 and 13 Aug | Android activity metrics must exclude these days; the conversion metric is unaffected |
| 16 | events | Bot-like users with very high event volumes | Events per user distribution | TODO: number of users and threshold | Stored in `bot_users` and excluded from the analysis population |
| 17 | events | No uninstall event type | Distinct event types | n/a | The uninstall guardrail was dropped; unsubscribe and refund guardrails are used |
| 18 | costs | Control arm has small non-zero costs although it receives no message | Cost totals by variant | Total of about 2.0 | Reported as-is; costs are not used in conclusions |
| 19 | subscriptions | Numeric columns loaded as text gave wrong min and max (for example max price 6.1 above min 239.23) | Implausible ranges in the first price check | n/a | Re-ran the checks after casting to numeric types |

No duplicate primary keys were found in `users`, `events`, `subscriptions` or `costs`. There were no orphan users in assignments or events.

## 2. Cleaning steps by table

**users_clean**
- Parsed `signup_date` into a `DATETIME` column (`signup_ts`) and dropped the text column.
- Standardised country labels, trimmed text, lowercased `platform` and `user_type`, replaced blanks with `Unknown` or `unknown`.
- Converted `email_opt_in` to 0/1.
- Primary key on `user_id`.

**ea_clean (experiment assignments)**
- Parsed `assignment_timestamp` into `assignment_ts` and dropped the text column.
- Lowercased `variant`; converted `exposure_flag` to 0/1.
- Deleted users with more than one variant, then kept the earliest row per user with `ROW_NUMBER()`.
- Primary key on `user_id` (one row per user).

**subscriptions_clean**
- Deleted orphan subscriptions.
- Parsed `start_date` into `start_ts` and dropped the text column.
- Lowercased `plan` and `status`, uppercased `currency`, converted `refunded_flag` to 0/1.
- Added `price_suspect`, set when the price is more than twice or less than half of the median price for its plan and currency. The median is used instead of the average because the outliers distort the average.
- Primary key on `subscription_id`, index on `user_id`.

**c_events_clean**
- Parsed `event_timestamp` into `event_ts` and dropped the text column.
- Lowercased `event_type` and `channel`.
- Primary key on `event_id`, index on `user_id`.
- Created `bot_users` from users with an abnormal number of events.

**c_costs_clean**
- Parsed `date` into `cost_date` (`DATE`) and dropped the text column.
- Lowercased `variant` and `channel`.
- Primary key on (`cost_date`, `variant`, `channel`).

### `parse_ts()` helper

A MySQL function that tries four formats in order (`DD/MM/YYYY HH:MM:SS`, `DD/MM/YYYY`, `YYYY-MM-DD HH:MM:SS`, `YYYY-MM-DD`) and returns the first match. After each parse, a check confirmed that no timestamps were left as NULL.

## 3. Data type changes

| Table | Column | From | To |
|---|---|---|---|
| users_clean | signup_date | text | `DATETIME` (`signup_ts`) |
| users_clean | prior_sessions_30d | text | `INT` |
| users_clean | email_opt_in | text | `TINYINT(1)` |
| ea_clean | assignment_timestamp | text | `DATETIME` (`assignment_ts`) |
| ea_clean | exposure_flag | text | `TINYINT(1)` |
| subscriptions_clean | price | text | `DECIMAL(14,2)` |
| subscriptions_clean | refunded_flag | text | `TINYINT(1)` |
| subscriptions_clean | start_date | text | `DATETIME` (`start_ts`) |
| c_events_clean | event_timestamp | text | `DATETIME` (`event_ts`) |
| c_costs_clean | date | text | `DATE` (`cost_date`) |
| c_costs_clean | impressions | text | `INT` |
| c_costs_clean | cost | text | `DECIMAL(14,6)` |

Price and cost use `DECIMAL`, not integers, so cents are not lost.

## 4. Row counts after cleaning

| Table | Rows | Check |
|---|---|---|
| users_clean | 60,000 | Same as raw |
| ea_clean | 59,700 | 60,900 raw rows, minus 300 conflicting users, minus 600 repeated rows |
| subscriptions_clean | 6,965 | 7,000 minus 35 orphans |
| c_events_clean | 611,877 | Same as raw (nothing deleted; issues are flagged) |
| c_costs_clean | 252 | Same as raw |
| analysis_users | 28,266 | Users assigned by 14 Aug, excluding bots and pre-assignment subscribers (9,682 control, 9,323 variant B, 9,261 variant C) |

## 5. Analysis table (`analysis_users`)

One row per eligible user. Columns: `user_id`, `variant`, `assignment_ts`, `platform`, `country`, `user_type`, `age_group`, `acquisition_channel`, `prior_sessions_30d`, `converted_14d`, `refunded_14d`, `unsub_14d`.

Definitions:
- `converted_14d`: first subscription between assignment and 14 days after assignment.
- `refunded_14d`: that subscription was refunded.
- `unsub_14d`: an unsubscribe event within 14 days of assignment.
- `net_converted` (created in the notebooks): converted and not refunded.
