# Infrastructure (Terraform)

This folder contains a minimal, secure, and cost-aware AWS data landing/processing setup using Terraform modules.

## Layout
- modules/s3: Raw + curated buckets, KMS CMK, lifecycle, policies
- modules/iam: Databricks instance profile + CI/CD role
- modules/budget: AWS Budget alert at 80%
- modules/config: AWS Config recorder + S3 public access rule

## Prerequisites
- Terraform >= 1.5
- AWS credentials in your environment

## Configure
Update terraform.tfvars with your organization values (tags, emails, principals):

```hcl
aws_region = "us-east-1"
name_prefix = "data-landing"

budget_amount = 500
budget_alert_emails = ["finops@example.com"]

cicd_principal_arns = ["arn:aws:iam::123456789012:role/ci-cd-role"]

tags = {
  App        = "data-landing"
  Env        = "dev"
  Owner      = "data-platform"
  CostCenter = "0000"
}
```

## Initialize
```bash
terraform init
```

## Validate
```bash
terraform validate
```

## Plan (no apply)
```bash
terraform plan -no-color -var-file=terraform.tfvars
```

### Sample plan output
```text
Terraform will perform the following actions:

  # module.s3.aws_kms_key.s3 will be created
  + resource "aws_kms_key" "s3" {
      + arn                       = (known after apply)
      + description               = "KMS CMK for S3 encryption"
      + enable_key_rotation       = true
      + deletion_window_in_days   = 30
    }

  # module.s3.aws_s3_bucket.raw will be created
  + resource "aws_s3_bucket" "raw" {
      + bucket = "data-landing-raw-123456789012"
    }

  # module.s3.aws_s3_bucket.curated will be created
  + resource "aws_s3_bucket" "curated" {
      + bucket = "data-landing-curated-123456789012"
    }

  # module.iam.aws_iam_role.databricks will be created
  + resource "aws_iam_role" "databricks" {
      + name = "data-landing-databricks"
    }

  # module.config.aws_config_config_rule.s3_public will be created
  + resource "aws_config_config_rule" "s3_public" {
      + name = "data-landing-s3-public"
    }

Plan: 28 to add, 0 to change, 0 to destroy.
```

Note: The actual plan output will vary by account, region, and input values. Capture a fresh plan with your credentials before submitting.

## CI Integration (brief)
- Use GitHub Actions with a matrix of workspaces (e.g., dev/stage/prod).
- Jobs run terraform fmt, validate, and plan for each workspace.
- Apply step is gated by manual approval or protected branches.

Example matrix idea:
- matrix.workspace: ["dev", "stage", "prod"]
- steps per workspace:
  - terraform init
  - terraform workspace select/create
  - terraform validate
  - terraform plan -var-file=terraform.<workspace>.tfvars
