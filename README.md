# MLOps-GCP

IaC for MLOps on Google Cloud Platform

## Requirements

- A [Google Cloud Platform](https://console.cloud.google.com) account
- [Terraform](https://developer.hashicorp.com/terraform) >= 1.14

## Architecture

- Artifact Registry: Repository for MLflow Docker container
- Cloud SQL: MLflow back-end store (PostgreSQL) for experiment tracking
- Cloud Storage: bucket for MLflow artifacts store
- Cloud Run: Serves MLflow container
- Secrets Manager: Securely stores database credentials and sensitive URIs
- IAM: Manages service account permissions to architecture components

## Download and Installation

### Download
Open Cloud Shell on GCP and run `git clone https://github.com/keiferc/mlops-gcp.git`.

### Installation
Deploy infrastructure:
```bash
# Set variables
cd mlops-gcp/terraform/
cp terraform.tfvars.example terraform.tfvars # fill placeholders

# Enable APIs and config Artifact Registry
gcloud services enable cloudresourcemanager.googleapis.com --project=<PROJECT_ID>
terraform init
terraform validate
terraform plan # check plan logic
terraform apply -target=google_project_service.apis # enable APIs
terraform apply -target=google_artifact_registry_repository.mlflow

# Authenticate Docker and push the MLflow image to Artifact Registry
cd ../docker/
gcloud auth configure-docker <REGION>-docker.pkg.dev
gcloud builds submit --tag <REGION>-docker.pkg.dev/<PROJECT_ID>/mlflow-repo/mlflow:latest --project <PROJECT_ID> .

# Deploy infrastructure
cd ../terraform/
terraform plan # check plan logic
terraform apply
```

## Usage

Inspect resources with `terraform show` and destroy resources with `terraform destroy`.

View MLFlow UI on Cloud Shell by running:
```bash
gcloud run services proxy mlflow-server --region=<REGION> --project=<PROJECT_ID> --port=8080
```
Then click the Web Preview icon.

## Contributing

### Requirements
- [uv](https://docs.astral.sh/uv/) >= 0.10

### Installation
```bash
uv sync --dev
uv run pre-commit autoupdate
uv run pre-commit install
```

### Guidelines

- Write self-documenting code
- Manage dependencies with `uv` (e.g., `uv add polars`)
- Submit pull requests to `dev`
