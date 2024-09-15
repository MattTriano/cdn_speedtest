MAKEFILE_DIR_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
INFRA_DIR := $(MAKEFILE_DIR_PATH)infra
SRC_DIR := $(MAKEFILE_DIR_PATH)src
SITE_SRC_DIR := $(SRC_DIR)/website
BUILD_DIR := $(MAKEFILE_DIR_PATH)build
LAMBDA_SRC_DIR := $(SRC_DIR)/lambda
LAMBDA_PKG_DIR := $(MAKEFILE_DIR_PATH)lambda_pkg
ZIP_PKG_PATH := $(INFRA_DIR)/lambda_function.zip


package:
	rm -rf $(LAMBDA_PKG_DIR)
	rm -f $(ZIP_PKG_PATH)
	mkdir -p $(LAMBDA_PKG_DIR)
	pip install -r $(LAMBDA_SRC_DIR)/requirements.txt -t $(LAMBDA_PKG_DIR)
	cp $(LAMBDA_SRC_DIR)/route_data.py $(LAMBDA_PKG_DIR)
	cd $(LAMBDA_PKG_DIR) && zip -r $(ZIP_PKG_PATH) .
	cp $(LAMBDA_SRC_DIR)/route_data.py .
	zip -g $(ZIP_PKG_PATH) route_data.py
	rm route_data.py

plan:
	cd $(INFRA_DIR) && tofu plan --var-file=$(INFRA_DIR)/secrets.tfvars

apply:
	cd $(INFRA_DIR) && tofu apply --var-file=$(INFRA_DIR)/secrets.tfvars

build: apply
	mkdir -p $(BUILD_DIR)
	cp -r $(SITE_SRC_DIR)/* $(BUILD_DIR)
	$(eval api_gateway_url := $(shell cd infra && tofu output -raw api_gateway_url))
	$(eval domain_name := $(shell cd infra && tofu output -raw domain_name))
	$(eval tld := $(shell cd infra && tofu output -raw tld))
	sed -i 's|{{api_gateway_url}}|$(api_gateway_url)|g' $(BUILD_DIR)/index.html
	sed -i 's|{{domain_name}}|$(domain_name)|g' $(BUILD_DIR)/index.html
	sed -i 's|{{tld}}|$(tld)|g' $(BUILD_DIR)/index.html

deploy-static: build
	$(eval site_bucket := $(shell cd infra && tofu output -raw website_bucket_name))
	aws s3 sync $(BUILD_DIR) s3://$(site_bucket)
	aws cloudfront create-invalidation --distribution-id \
		$(shell cd infra && tofu output -raw cloudfront_distribution_id) --paths "/*"
