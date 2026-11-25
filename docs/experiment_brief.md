# Experiment Brief: AI Learning Assistant Campaign

## Problem

LearnLoop launched an AI-powered learning assistant, but adoption is low. The team needs to know whether a campaign can increase premium conversions, which message works best, and which users to target.

## Hypotheses

- **H1:** Users who receive the benefit-focused message (Variant B) convert to premium at a higher rate than control.
- **H2:** Users who receive the discount-focused message (Variant C) convert to premium at a higher rate than control.
- **H3 (guardrail):** Neither variant increases unsubscribes or refunds compared with control.

## Design

| Item | Detail |
|---|---|
| Unit of randomisation | User |
| Arms | Control (no message), Variant B (benefit-focused), Variant C (discount-focused) |
| Intended split | About 34% / 33% / 33% |
| Duration | 28 days, 1-28 Aug 2026 |
| Channels | Email, push, in-app |

## Metrics

| Type | Metric | Definition |
|---|---|---|
| Primary | Premium conversion | First subscription within 14 days of assignment |
| Secondary | Conversion net of refunds | Converted and not refunded |
| Guardrail | Unsubscribe rate | Unsubscribe event within 14 days of assignment |
| Guardrail | Refund rate | Converted subscription that was refunded |

The original plan also included an uninstall guardrail. The data has no uninstall event, so it was dropped.

## Analysis population

- Users assigned by 14 Aug 2026, so every user has a full 14-day outcome window (subscription data ends on 28 Aug).
- Excluded: users with conflicting variant assignments, bot-like users, and users who subscribed before their assignment.
- Result: 28,266 users (9,682 control, 9,323 Variant B, 9,261 Variant C).

## Statistical plan (as executed)

1. Sample ratio mismatch check (chi-square test against the intended split).
2. Two-proportion z-test for each variant vs control, with a 95% confidence interval for the difference in percentage points. Bonferroni adjustment for the two variant comparisons, applied to the primary metric and the guardrails.
3. Net-of-refund conversion tested the same way, plus a direct comparison of Variant C with Variant B.
4. Exploratory segment analysis by platform and country (segments with at least 300 control users: 11 segments, 22 comparisons), with a Bonferroni correction across all 22.
5. Targeting analysis: a cross-fitted two-model uplift estimate (gradient boosting), measured uplift by predicted-uplift quintile, gain curves against random targeting, and a comparison with the simple rule "Variant C for Android users in India."

With about 9,300 to 9,700 users per arm and a 4.8% baseline, the smallest lift this design can detect is about 0.9 percentage points (80% power, 5% two-sided significance, approximate).

## Decision rule

Launch a variant if conversion improves significantly and no guardrail worsens significantly. If a variant wins on conversion but harms a guardrail, treat it as a targeted option and not a default.

## Assumptions and risks

- Assignment is random, checked through the sample ratio test (p = 0.60).
- Users who subscribed before assignment are not affected by the campaign.
- Data is synthetic; effect sizes are larger than typical real experiments.
- Outcomes beyond 14 days, and feature adoption itself (use of the AI assistant), are not measured.
