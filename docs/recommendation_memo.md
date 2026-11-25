# Recommendation Memo: AI Learning Assistant Campaign

**To:** LearnLoop Product and Growth leadership
**Subject:** Campaign launch decision
**Note:** Based on a synthetic dataset created for a portfolio project.

## Decision

**Launch the campaign.** Roll out **Variant B (benefit-focused message)** to all eligible users, and use **Variant C (discount-focused message)** only for Android users in India, with refund monitoring. Target with this simple rule, not a model.

## Why

Both messages raised 14-day premium conversion over the control group (4.84%):

| | Variant B | Variant C |
|---|---|---|
| Conversion | 6.96% | 7.52% |
| Lift | +2.1 pp (95% CI 1.4 to 2.8) | +2.7 pp (95% CI 2.0 to 3.4) |
| Lift net of refunds | +2.10 pp (95% CI 1.4 to 2.8) | +2.19 pp (95% CI 1.5 to 2.9) |
| Unsubscribes vs control | +0.15 pp, not significant | +0.44 pp, not significant |
| Refund rate | 0.24% (control 0.22%) | 0.70%, about 3x control |
| Refunds as share of converters | 3.4% | 9.3% |

Variant C converts a little more, but a larger share of those customers ask for refunds. After refunds, B and C deliver the same benefit, and B does so with no guardrail cost.

## Answers to the business questions

1. **Should we launch?** Yes. The improvement is statistically significant for both variants, and the arms were balanced (sample ratio test p = 0.60).
2. **Which message performs best?** B for a broad rollout. C converts 0.55 pp more than B, but that difference is not significant (95% CI -0.19 to 1.30, p = 0.14), and net of refunds the two are the same (+0.09 pp, 95% CI -0.63 to 0.81). C's refund rate is 0.47 pp higher than B's (p < 0.001).
3. **Which segments respond best?** Variant C on Android in India: +4.0 pp (95% CI 2.5 to 5.5), still +3.4 pp after subtracting refunds. It is the only segment result that holds after correcting for all 22 segment comparisons. Android in Indonesia looks promising (about +4 pp for both variants) but is not conclusive. Variant C does not help iOS users in the USA. Other segments are inconclusive.
4. **Is the improvement statistically significant?** Conversion: yes, for both variants (p < 0.001). Unsubscribes: no significant change. Refunds: significantly higher for C only.
5. **Everyone or targeted?** B to everyone; C targeted at Android users in India. An uplift model did not rank users reliably, so use the simple rule. Messaging only Android users in India (22% of users) captures 33% of C's total incremental conversions, against 17% for the model's top 22%.

## Risks and limitations

- The data is synthetic, and the lifts are larger than typical real-world campaigns.
- The analysis covers users assigned by 14 Aug, so effects beyond two weeks and possible novelty effects are unknown.
- Segment results involve many comparisons. Only Android India holds after correction, and it should be confirmed in a follow-up experiment.
- Campaign cost data in this dataset is too small to support a meaningful ROI estimate.
- Premium conversion is the measured outcome. Use of the AI assistant itself and channel-level performance were not analysed.

## Next steps

1. Confirm Variant C in Android India (and Android Indonesia) in a follow-up experiment that runs longer than 14 days.
2. Monitor C's refund rate in any targeted rollout.
3. Analyse feature adoption (feature view to feature use) and channel performance (email, push, in-app).
4. Revisit the uplift model with more data or richer features.
