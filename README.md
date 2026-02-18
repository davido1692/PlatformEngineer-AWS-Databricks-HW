# PlatformEngineer-AWS+Databricks Repository

This repo contains four sections: Infrastructure (Terraform), Databricks pipelines, FinOps analysis, and SQL analytics.

## Repo layout
- infra/: Terraform modules and root config
- pipelines/: Databricks policies, job config, and ingestion script
- finops/: Cost analysis and controls
- sql/: Analytics SQL
- docs/: Overall documentation and evaluation checklist

## How to run

### Infrastructure (Terraform)
```bash
cd infra
terraform init
terraform validate
terraform plan -no-color -var-file="terraform.tfvars"
```

### Pipelines (Databricks)
1. Update placeholders in cluster policy and job configs:
   - pipelines/cluster_policy.json
   - pipelines/job.json
2. Upload the five CSVs to the raw S3 landing bucket:
   - Batting.csv, CollegePlaying.csv, People.csv, Salaries.csv, Schools.csv
3. Run the ingestion job:
   - Use pipelines/landing_to_curated.py as a single-notebook task or job script.

```python
for table_name, cfg in TABLES.items():
    source_df = read_csv(cfg["path"], cfg["schema"])
    cleaned_df = run_dq_checks(source_df, cfg["keys"])
    write_delta(cleaned_df, table_name, cfg["partition_cols"])

```

### FinOps
```bash
python finops/analyze_costs.py
```
Outputs:
- finops/analysis_summary.md
- finops/FINOPS_REPORT.md

Controls:
- finops/databricks_pool_spot.json
- finops/aws_budget_tag_filter.tf

### SQL
Use sql/team_efficiency.sql in your warehouse or Spark SQL engine.

## Notes
- See docs/README.md for architecture, security, evaluation checklist, and known gaps.
