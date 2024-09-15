# CDN Speedtest

This project experiments with setting up infrastructure (via `terraform`/`OpenTofu`) to serve a [speed test](https://github.com/openspeedtest/Speed-Test) via a CDN and collect the speed measurement data.

## Prerequisites

To follow these instructions, you will need to have:
* either `terraform` or `OpenTofu` (an open-license fork of `terraform`) installed,
* the AWS CLI installed and configured with credentials, and
* `make` (you can get by without this, but you'll have to adapt the `Makefile` recipes to your context)

## Secrets

Create a file in `/infra/` named `secrets.tfvars` and fill in the following variables for your situation.

```tf
aws_region           = "us-east-2"
domain_name          = "SampleWebsiteDomainName"
tld                  = "com"
website_bucket_name  = "bucket-for-your-website-files"
data_bucket_name     = "bucket-for-your-speedtest-data"
```

Note: you'll have to own the `domain_name` in the indicated top level domain (`tld`), and this project assumes that domain is registered through AWS's domain registry `Route 53`.

## Usage

Run `make package` to prepare the zipped up lambda_func zip archive.
Run `make plan` to plan out tofu resources.
Run `make apply` to apply the plan and create the resources.
Run `make deploy-static` to push the site files up into the `website_bucket`.

