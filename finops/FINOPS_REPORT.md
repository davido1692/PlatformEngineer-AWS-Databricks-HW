# FinOps Mini-Case

## Data summary
Source: data/aws_costs.csv

Aggregate totals:
- Total spend: $1,479.20
- Top service: AmazonEC2 ($1,085.00, 73.4%)
- Top usage: BoxUsage:m5.large ($990.00, 66.9%)

Top cost drivers (from analysis):
- AmazonEC2 (73.4% of spend), dominated by BoxUsage:m5.large
- EC2-Other (14.6%) mostly EBS gp3 volume + IOPS
- AmazonS3 (9.8%) timed storage

Tag coverage gaps:
- Owner: 87 rows missing ($47.00, 3.2% of spend)
- CostCenter: 85 rows missing ($40.70, 2.8% of spend)
- App/Env: missing on 83 rows (no spend impact in this dataset, but still a governance gap)

## Cost distribution charts (text)
Top services:
- AmazonEC2        | ############################### 73.4%
- EC2-Other        | ######                          14.6%
- AmazonS3         | ####                            9.8%
- AmazonCloudWatch | #                               1.8%
- AWSLambda        | .                               0.3%

Top usage types:
- BoxUsage:m5.large        | ########################### 66.9%
- EBS:VolumeUsage.gp3      | #####                       13.1%
- TimedStorage-ByteHrs     | ####                        8.4%
- SpotUsage:c5.large       | ###                         6.4%
- EBS:VolumeIOPS.gp3       | #                           1.5%

## Savings actions (rough estimates)
1) Shift on-demand EC2 to Savings Plans and spot pools
   - Base: BoxUsage:m5.large = $990.00
   - If 35% blended reduction (Savings Plans + Spot pools) => ~$346.50/month

2) EBS gp3 rightsizing and cleanup
   - Base: EBS gp3 volume + IOPS = $216.30
   - If 20% reduction (trim size, delete unattached, reduce IOPS) => ~$43.26/month

3) S3 lifecycle for raw data
   - Base: S3 TimedStorage-ByteHrs = $124.05
   - If 30% reduction (move to IA after N days) => ~$37.22/month

Total estimated savings: ~$426.98/month (order of magnitude)

## Controls implemented in code
1) Databricks pool config using Spot with fallback
   - File: finops/databricks_pool_spot.json
   - Supports the Spot/Pool savings action and faster job startup.

2) AWS Budget with tag filter
   - File: finops/aws_budget_tag_filter.tf
   - Enforces budget guardrails per tag (e.g., CostCenter).

## Notes
- Cluster policy and S3 lifecycle are already implemented in infra/pipelines and reinforce these actions.
- Replace placeholders (emails, tags, pool names) before use.
