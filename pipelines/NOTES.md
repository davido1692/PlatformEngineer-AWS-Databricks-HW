# Notes

## Data quality checks and idempotency
- The job ingests five CSVs from the S3 landing bucket into curated Delta tables.
- Rows missing business keys are dropped to avoid dirty joins downstream.
- Year range validation keeps obvious bad data out of curated tables.
- Overwrite + checkpointed Delta writes make the job safe to re-run.
- Stable checkpoint paths live in curated storage for visibility and cleanup.

## Partitioning and write mode
- Batting, CollegePlaying, and Salaries partition by yearID for pruning.
- People and Schools are small and stay unpartitioned to avoid tiny files.
- Overwrite mode ensures deterministic outputs for batch reprocessing.

## Access control notes (Unity Catalog)
- Suggested structure: catalog = "baseball", schemas = "raw" and "curated".
- Raw schema is read-only for analysts; curated schema allows ETL service principals.
- External locations map to raw/curated buckets via storage credentials tied to the instance profile.

## Secrets
- Use Databricks Secret Scopes for API keys or webhooks.
- Use AWS instance profiles for S3 access so no static keys live in code.

## Observability
- Job JSON includes failure email notifications and retries.
- Add log delivery or system table monitoring where available.
