# MLOps-GCP

IaC for MLOps on Google Cloud Platform

## Requirements

- A [Google Cloud Platform](https://console.cloud.google.com) account
- [Terraform](https://developer.hashicorp.com/terraform) >= 1.14

## Downdload and Installation

Open Cloud Shell on GCP and run:

```bash
$ git clone https://github.com/keiferc/mlops-gcp.git
$ cd mlops-gcp
$ terraform init
$ terraform apply
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
