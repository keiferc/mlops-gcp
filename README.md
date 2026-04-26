# MLOps-GCP

IaC for MLOps on Google Cloud Platform

## Requirements

- A [Google Cloud Platform](https://console.cloud.google.com) account
- [Terraform](https://developer.hashicorp.com/terraform) >= 1.14

## Architecture

- Artifact Storage: Cloud Storage bucket for MLflow artifacts
- Database: Cloud SQL (PostgreSQL) for experiment tracking
- Credentials: Secret Manager for secure database credentials
- Container Registry: Artifact Registry to store MLflow Docker container
- Compute: Cloud Run to host MLflow UI

## Download and Installation

### Download
Open Cloud Shell on GCP and run `git clone https://github.com/keiferc/mlops-gcp.git`.

### Installation
Deploy infrastructure:
```bash
$ cd mlops-gcp/terraform/
$ cp terraform.tfvars.example terraform.tfvars # replace placeholders w/ real values
$ gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com --project={project-id}
$ terraform init
$ terraform validate
$ terraform plan
$ terraform apply
```

Deploy MLflow container:
```bash
$ cd ../docker/
$ gcloud auth configure-docker $(terraform output -raw artifact_registry_image_url | cut -d/ -f1)
$ docker build -t mlflow:latest .
$ docker tag mlflow:latest $(terraform output -raw artifact_registry_image_url):latest
$ docker push $(terraform output -raw artifact_registry_image_url):latest
$ terraform apply -target=google_cloud_run_v2_service.mlflow
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
