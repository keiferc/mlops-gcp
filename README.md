# MLOps-GCP

IaC for MLOps on Google Cloud Platform

## Requirements

- A [Google Cloud Platform](https://console.cloud.google.com) account
- [Terraform](https://developer.hashicorp.com/terraform) >= 1.14

## Architecture

- Artifact Storage: Cloud Storage bucket for MLflow artifacts
- Database: Cloud SQL (PostgreSQL) for experiment tracking
- Credentials: Secret Manager for secure database credentials
- Container Registry: Artifact Registry to store MLflow Docker image
- Compute: Cloud Run to host MLflow UI (private, accessible via GCP Console)

## Downdload and Installation

Open Cloud Shell on GCP and run:

```bash
$ git clone https://github.com/keiferc/mlops-gcp.git
$ cd mlops-gcp/src/
$ cp terraform.tfvars.example terraform.tfvars # replace placeholders w/ real values
$ terraform init
$ terraform apply
$ docker build -t <region>-docker.pkg.dev/<gcp-project-name>/mlflow/mlflow:latest .
$ docker push <region>-docker.pkg.dev/<gcp-project-name>/mlflow/mlflow:latest
```

## Usage

Inspect resources with `terraform show` and destroy resources with `terraform destroy`.


## Contributing

### Requirements
- [uv](https://docs.astral.sh/uv/) >= 0.10

### Installation
```bash
$ uv sync --dev
$ uv run pre-commit autoupdate
$ uv run pre-commit install
```

### Guidelines

- Write self-documenting code
- Manage dependencies with `uv` (e.g., `uv add polars`)
- Submit pull requests to `dev`
