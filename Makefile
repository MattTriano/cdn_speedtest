MAKEFILE_DIR_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
INFRA_DIR := $(MAKEFILE_DIR_PATH)infra
SRC_DIR := $(MAKEFILE_DIR_PATH)src
SITE_SRC_DIR := $(SRC_DIR)/website
BUILD_DIR := $(MAKEFILE_DIR_PATH)build

plan:
	cd $(INFRA_DIR) && tofu plan --var-file=$(INFRA_DIR)/secrets.tfvars

apply:
	cd $(INFRA_DIR) && tofu apply --var-file=$(INFRA_DIR)/secrets.tfvars

build: apply
	mkdir -p $(BUILD_DIR)
	cp -r $(SITE_SRC_DIR)/* $(BUILD_DIR)
	$(eval domain_name := $(shell cd infra && tofu output -raw domain_name))
	$(eval tld := $(shell cd infra && tofu output -raw tld))
	sed -i 's|{{domain_name}}|$(domain_name)|g' $(BUILD_DIR)/index.html
	sed -i 's|{{tld}}|$(tld)|g' $(BUILD_DIR)/index.html


deploy-static: build
	$(eval site_bucket := $(shell cd infra && tofu output -raw website_bucket_name))
	aws s3 sync $(BUILD_DIR) s3://$(site_bucket)
	aws cloudfront create-invalidation --distribution-id \
		$(shell cd infra && tofu output -raw cloudfront_distribution_id) --paths "/*"
