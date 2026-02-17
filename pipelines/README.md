# Pipelines

## Files
- cluster_policy.json: Cluster policy enforcing cost and security controls. Use this to prevent drift from guardrails.
- cluster_policy_notes.md: Field-by-field explanation for the policy JSON.
- job.json: Databricks job definition with retry and failure alerts. Safe defaults for small batch ingestion.
- job_notes.md: Field-by-field explanation for the job JSON.
- landing_to_curated.py: PySpark ingestion from raw S3 to curated Delta. Includes DQ filters and idempotent writes.
- NOTES.md: DQ, idempotency, access control, and observability notes.

## Usage
- Import landing_to_curated.py as a notebook or run as a job task.
- Update placeholders for S3 buckets, instance profile ARN, pool id, and notebook path.
- Keep raw data immutable; re-runs are safe because curated writes overwrite deterministically.
- The job expects five CSVs in S3 landing: Batting, CollegePlaying, People, Salaries, Schools.

## What to edit and where
- pipelines/landing_to_curated.py: edit RAW_BASE, CURATED_BASE, CHECKPOINT_BASE.
- pipelines/landing_to_curated.py: change write format (parquet for local, delta for Databricks).
- pipelines/job.json: update notebook_path and instance_profile_arn.
- pipelines/cluster_policy.json: update instance_pool_id and instance_profile_arn.

## Exact code blocks to update
### Local paths (replace at top of landing_to_curated.py)
```python
RAW_BASE = "file:///workspaces/data"
CURATED_BASE = "file:///workspaces/output/curated"
CHECKPOINT_BASE = "file:///workspaces/output/checkpoints"
```

### Databricks paths (replace at top of landing_to_curated.py)
```python
RAW_BASE = "s3://__RAW_BUCKET__/landing"
CURATED_BASE = "s3://__CURATED_BUCKET__/curated"
CHECKPOINT_BASE = "s3://__CURATED_BUCKET__/checkpoints"
```

### Local write format (Parquet)
```python
writer = (
    df.write
    .format("parquet")
    .mode("overwrite")
)
```

### Databricks write format (Delta)
```python
writer = (
    df.write
    .format("delta")
    .mode("overwrite")
    .option("overwriteSchema", "true")
    .option("checkpointLocation", checkpoint_path)
)
```


### Databricks job
1) Upload the five CSVs to the S3 landing bucket under the landing/ prefix.
2) In Databricks, import the script:
    - Workspace > Repos (or Workspace) > Add > Upload File
    - Upload pipelines/landing_to_curated.py (or paste it into a new notebook).
3) Create a job:
    - Workflows > Jobs > Create Job
    - Add a task of type "Notebook" and select the uploaded notebook/script.
4) Configure the job cluster:
    - Use a Job Cluster (not all-purpose).
    - Apply the cluster policy from pipelines/cluster_policy.json.
    - Set the instance profile ARN for S3 access.
5) Set parameters/placeholders:
    - Replace __RAW_BUCKET__ and __CURATED_BUCKET__ in the script or pass as widget values.
6) Run the job and verify curated outputs under s3://__CURATED_BUCKET__/curated.

### Local PySpark (no Databricks)
1) Install PySpark and Java (JDK 17 recommended as tested on JDK 17).
```python
    python -m pip install pyspark
```
    - Ensure JAVA_HOME points to JDK 17 (Spark 4.x requires it)
2) Update the paths in landing_to_curated.py to local file paths:
```python
    - RAW_BASE = "file:/C:/path/to/data"
    - CURATED_BASE = "file:/C:/path/to/output"
    - CHECKPOINT_BASE = "file:/C:/path/to/output/checkpoints"
```
3) Run the job:
```spark
    spark-submit pipelines/landing_to_curated.py
```

### Local vs Databricks output format
- Local testing: use Parquet to avoid Delta dependencies in local Spark.
- Databricks: use Delta format for production tables and ACID support.
- If you switch between the two, update the write format in landing_to_curated.py accordingly.
