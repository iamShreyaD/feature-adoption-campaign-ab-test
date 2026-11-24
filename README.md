# LearnLoop AI Assistant Campaign: A/B Test Analysis

**Should LearnLoop launch a campaign promoting its new AI learning assistant, which message works best, and who should receive it?**

> **Note: synthetic data.** All data in this project was generated for portfolio purposes and contains deliberately planted data quality issues and effects. The results show how I would analyse and decide on a real experiment. They are not findings about a real company.

## Business problem

LearnLoop is a subscription-based learning app (Python, mathematics, communication skills, data analytics). It recently launched an AI-powered learning assistant that explains concepts, answers questions, creates practice questions and helps students understand mistakes. Few users are trying it, so the team ran a 28-day campaign (1-28 Aug 2026) with three arms:

- **Control:** no campaign message
- **Variant B:** benefit-focused message
- **Variant C:** discount-focused message

Business questions: Should the company launch the campaign? Which variant performs best? Which segments respond best? Is the improvement statistically significant? Should it roll out to everyone or target segments?

## Key results

Primary metric: premium subscription within 14 days of assignment. Guardrails: unsubscribes and refunds.

| Metric (14 days) | Control | Variant B | Variant C |
|---|---|---|---|
| Users analysed | 9,682 | 9,323 | 9,261 |
| Premium conversion | 4.84% | 6.96% | 7.52% |
| Lift vs control | n/a | +2.12 pp (95% CI 1.45 to 2.79) | +2.67 pp (95% CI 1.99 to 3.36) |
| Unsubscribe rate | 8.10% | 8.25% (+0.15 pp, not significant) | 8.54% (+0.44 pp, not significant) |
| Refund rate (share of users) | 0.22% | 0.24% (not significant) | 0.70% (+0.49 pp, 95% CI 0.30 to 0.69) |
| Refunds as share of converters | 4.5% | 3.4% | 9.3% |

- Both variants significantly increase conversion (p < 0.001, Bonferroni-adjusted for two comparisons).
- Variant C converts slightly more than B, but its refund rate is about 3x control, which cancels out most of the extra conversions. After refunds, B and C retain roughly the same share of users (about 6.7% and 6.8%, vs about 4.6% for control).
- Arm sizes are balanced (sample ratio mismatch test: p = 0.60).
- Segments (exploratory): Variant C on **Android in India** shows the clearest lift (+4.0 pp, 95% CI 2.5 to 5.5) and survives correction for all 22 segment comparisons. Android in Indonesia shows about +4 pp for both variants but is only suggestive after correction. Variant C is flat for iOS in the USA (-0.5 pp, not significant).

## Recommendation

1. **Launch the campaign.** Both variants beat control.
2. **Roll out Variant B broadly.** It has no measurable guardrail cost.
3. **Use Variant C only in targeted segments** (Android in India first), with refund monitoring.
4. **Follow-up experiment:** test C vs B directly in the target segments, and run longer than 14 days to check for novelty effects.

## Approach

```
Raw CSVs  ->  MySQL staging tables  ->  validation checks  ->  cleaned tables  ->  analysis_users (one row per user)
                                                                                         |
                                                                       Google Colab: A/B tests, guardrails, segments
```

1. **MySQL (schema `fac`):** loaded raw CSVs as text into staging tables, ran validation checks, then cleaned and typed the data (see `docs/data_quality_log.md`).
2. **Analysis table:** built `analysis_users`, one row per eligible user, with the 14-day conversion, refund and unsubscribe flags.
3. **Python (Google Colab):** sample ratio check, two-proportion z-tests with confidence intervals for the difference, Bonferroni adjustment across the two variants, guardrail metrics, and exploratory segment analysis (platform x country, segments with at least 300 control users).

## Data

| Table | Rows | Description |
|---|---|---|
| users | 60,000 | Demographics, country, platform, acquisition channel, prior engagement |
| experiment_assignments | 60,900 | Variant, assignment timestamp, exposure flag (includes duplicates and conflicts) |
| subscriptions | 7,000 | Plan, price, currency, start date, status, refund flag |
| campaign_events | 611,877 | App opens, feature use, email and push events, unsubscribes |
| campaign_costs | 252 | Daily spend and impressions by variant and channel |

Analysis population: 28,266 users assigned by 14 Aug 2026, excluding bot-like users and users who subscribed before assignment.

## Data quality highlights

The raw data was intentionally messy. Issues found and handled include: 300 users assigned to more than one variant (removed) and 600 duplicate assignment rows, 35 orphan subscriptions, mixed date formats, country aliases, missing values, uppercase event labels, price and currency outliers, bot-like users with very high event volumes, events outside the experiment window or before signup, and an Android `app_open` logging outage on 12-13 Aug.

Two issues changed the analysis design:
- **Censored outcome window:** subscription data ends on the last assignment date (28 Aug), so users assigned after 14 Aug do not have a full 14-day window. The primary analysis is restricted to users assigned by 14 Aug.
- **Pre-assignment subscribers:** about half of subscriptions start before the user's assignment. These users are excluded because a purchase that happened before treatment cannot be caused by it.

Full details are in [`docs/data_quality_log.md`](docs/data_quality_log.md).

## Repository structure

```
feature-adoption-campaign-ab-test/
├── README.md
├── data/
│   ├── raw/                  # original CSVs
│   └── cleaned/              # analysis_users.csv exported from MySQL
├── sql/
│   ├── 01_create_and_load_staging_tables.sql
│   ├── 02_validation_checks.sql
│   ├── 03_cleaning.sql
│   └── 04_analysis_table_and_funnel.sql
├── notebooks/
│   ├── 01_ab_test_analysis_and_segments.ipynb
│   └── 02_uplift_model_and_targeting.ipynb   # in progress
├── docs/
│   ├── experiment_brief.md
│   ├── data_quality_log.md
│   └── recommendation_memo.md
└── reports/figures/
```

## Limitations

- Synthetic data: effects were planted, so effect sizes are larger than in typical real-world experiments.
- Only users assigned by 14 Aug are analysed, so novelty effects across the full 28 days cannot be assessed.
- Segment results are exploratory. With 22 comparisons, only the strongest result holds after correction.
- Campaign costs in the synthetic data are very small relative to subscription revenue, so ROI figures would be unrealistic and are not used for conclusions.
- Variant B vs Variant C has not yet been tested directly.

## Next steps

- Uplift model to identify users who respond because of the campaign, and a targeting simulation
- Direct B vs C comparison
- Channel and funnel analysis (email, push, in-app; feature view to feature use)
- Visualizations of results

## Tools

MySQL 8.0 and MySQL Workbench, Python (pandas, NumPy, SciPy, statsmodels), Google Colab, Git/GitHub.
