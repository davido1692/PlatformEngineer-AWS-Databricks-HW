# Project README

This document summarizes Sections A through D and how to run each part end-to-end.

## Section A: Infrastructure as Code (Terraform)
- Modules for S3, IAM, budgets, and AWS Config guardrails.
- S3 buckets enforce TLS-only access, block public access, and SSE-KMS encryption.
- KMS CMK with least-privilege usage and key rotation.
- Mandatory tags across resources for governance and cost allocation.
- AWS Config rule prevents public S3 buckets.
- CI/CD role is scoped to only required resources.

## Section B: Databricks Administration and Job Enablement
- Cluster policy enforces cost and security guardrails (autotermination, job clusters, pools).
- Job JSON includes retries and failure alerts.
- Ingestion job reads five CSVs from S3 landing and writes curated Delta tables.
- Idempotent overwrite writes with checkpointing and basic DQ checks.
- Unity Catalog structure and secret handling documented in pipelines/NOTES.md.

## Section C: FinOps Mini-Case
- Cost analysis from synthetic aws_costs.csv with top drivers and tag coverage.
- Savings actions proposed with rough estimates and supporting controls.
- Controls implemented: Spot pool config and tag-filtered budget.
- Outputs: finops/analysis_summary.md and finops/FINOPS_REPORT.md.

## Section D: ETL Development
- SQL aggregate builds one row per teamID, yearID with payroll and efficiency metrics.
- Batting aggregated to team-year across all players and stints.
- Salaries aggregated to team-year and left-joined to Batting.
- Deterministic ordering and NULL-safe math for stable results.

## How to deploy/run
- Infra (Terraform):
  - terraform init
  - terraform validate
  - terraform plan -no-color -var-file=terraform.tfvars
- Pipelines (Databricks):
  - Update placeholders in pipelines/cluster_policy.json and pipelines/job.json.
  - Upload landing CSVs to the raw S3 bucket.
  - Run pipelines/landing_to_curated.py via Databricks Jobs.
- FinOps analysis:
  - python finops/analyze_costs.py
- SQL:
  - Run sql/team_efficiency.sql in your warehouse or Spark SQL engine.

## How to test
- Terraform: terraform validate and terraform plan.
- Databricks: run the job in a dev workspace and verify curated Delta outputs.
- FinOps: re-run analyze_costs.py and review finops/analysis_summary.md.
- SQL: run sql/team_efficiency.sql and spot-check sample rows.

## Known gaps and next steps
- No automated CI pipeline yet; add GitHub Actions with plan/apply gates.
- No UC table registration in pipelines; add CREATE TABLE for curated tables.
- Add automated data quality checks (e.g., Great Expectations or Deequ).
- Expand FinOps analysis to include trend reporting and anomaly alerts.

## Evaluation checklist
- Infrastructure and security: KMS encryption, TLS-only buckets, public access blocks, least-privilege IAM, required tags, AWS Config rule.
- Cost discipline: budgets, lifecycle, spot pool config, quantified savings actions.
- Databricks admin maturity: cluster policy, job cluster, retries, failure alerts.
- Data pipeline enablement: idempotent ingestion, schema handling, basic DQ checks.
- SQL correctness and clarity: team-year aggregates, left join payroll, stable output.
