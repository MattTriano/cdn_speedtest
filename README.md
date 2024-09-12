# CDN Speedtest

This project experiments with setting up infrastructure (via `terraform`/`OpenTofu`) to serve a [speed test](https://github.com/openspeedtest/Speed-Test) via a CDN and collect the speed measurement data.

## Usage

Run `make package` to prepare the zipped up lambda_func zip archive.
Run `make plan` to plan out tofu resources.
Run 'make apply` to apply the plan and create the resources.


