# MLOps-GCP

IaC for MLOps on Google Cloud Platform

## Requirements

- A [Google Cloud Platform](https://console.cloud.google.com) account
- [Terraform](https://developer.hashicorp.com/terraform) >= 1.14

## Architecture

- Artifact Store: Cloud Storage bucket for MLflow artifacts
- Backend Store: Cloud SQL (PostgreSQL) for experiment tracking
- Credentials: Secret Manager for secure database credentials
- Container Registry: Artifact Registry to store MLflow Docker container
- Compute/Serve: Cloud Run to host MLflow server

## Download and Installation

### Download
Open Cloud Shell on GCP and run `git clone https://github.com/keiferc/mlops-gcp.git`.

### Installation
Deploy infrastructure:
```bash
cd mlops-gcp/terraform/
cp terraform.tfvars.example terraform.tfvars # fill placeholders

# Enable APIs
gcloud services enable cloudresourcemanager.googleapis.com --project=<PROJECT_ID>
terraform init
terraform validate
terraform plan
terraform apply -target=google_project_service.apis -target=google_artifact_registry_repository.mlflow -target=google_project_iam_member.artifact_registry_writer

# Authenticate Docker and push the MLflow image
cd ../docker/
gcloud auth configure-docker <REGION>-docker.pkg.dev
docker build -t <REGION>-docker.pkg.dev/<PROJECT_ID>/mlflow-repo/mlflow:latest .
docker push <REGION>-docker.pkg.dev/<PROJECT_ID>/mlflow-repo/mlflow:latest

# Deploy
terraform apply
```

## Usage

Inspect resources with `terraform show` and destroy resources with `terraform destroy`.


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
