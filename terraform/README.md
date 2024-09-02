# Terraform Configuration - README

## Overview

This folder contains Terraform configurations for managing infrastructure in AWS. The Terraform scripts are designed to automate the deployment and management of various AWS services, including ECS, EMR, Glue, IAM, MSK, and S3.

## Folder Structure

- **backend-setup.tf**: Contains configurations for setting up the Terraform backend.

- **ecs.tf**: Manages AWS Elastic Container Service (ECS) resources.

- **emr.tf**: Configurations for AWS Elastic MapReduce (EMR).

- **glue.tf**: AWS Glue-related configurations.

- **iam.tf**: Manages AWS Identity and Access Management (IAM) resources.

- **main.tf**: The main entry point for Terraform, orchestrating the creation of resources.

- **msk.tf**: Configurations for AWS Managed Streaming for Apache Kafka (MSK).

- **networking.tf**: Manages network configurations like VPC, subnets, and security groups.

- **outputs.tf**: Defines outputs from the Terraform state, making it easier to reference resource attributes.

- **s3.tf**: Manages AWS S3 buckets and related configurations.

- **terraform-tfvars-example.tf**: An example file to illustrate how to define variables used by Terraform.

- **updated-main.tf**: A more recent version of `main.tf` with updated configurations.

- **variables.tf**: Defines variables used throughout the Terraform configurations.

## Prerequisites

Before running the Terraform scripts, ensure you have the following:
- AWS CLI configured with the necessary access keys.
- Terraform installed (version 1.9.5 or compatible).
- S3 bucket and DynamoDB table configured for state storage (as per `backend-setup.tf`).

## Usage

### 1. Initialize the Terraform Working Directory

Run the following command to initialize the Terraform working directory:

```bash
terraform init
```

This will download the necessary provider plugins and set up the backend.

### 2. Plan the Infrastructure Changes

Use the `terraform plan` command to preview the changes Terraform will make:

```bash
terraform plan
```

Review the output to ensure that the planned changes align with your expectations.

### 3. Apply the Changes

Once you're satisfied with the plan, apply the changes to your infrastructure:

```bash
terraform apply
```

### 4. CI/CD Integration

This repository uses GitHub Actions for CI/CD. The workflow is defined in the `terraform.yml` file and is triggered on pushes to the `main` branch and pull requests affecting the `terraform` directory.

#### Key Workflow Steps:
- **Backend Setup**: Configures the backend for storing Terraform state files.
- **Terraform Init**: Initializes the Terraform configuration.
- **Terraform Plan & Apply**: Automatically plans and applies changes to the infrastructure.

Ensure your AWS credentials are securely stored in GitHub Secrets (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`).

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs/)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)