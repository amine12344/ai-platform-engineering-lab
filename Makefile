SHELL := /bin/bash

PATH := $(CURDIR)/.local/bin:$(PATH)
PROFILE ?= 16gb

.PHONY: help doctor install-kind cache-lab-0 create-cluster install-ingress \
	build-platform-health deploy-baseline bootstrap-lab-0 verify-lab-0 \
	incident-lab-0 recover-lab-0 evidence-lab-0 destroy-cluster destroy-all \
	install-lab-1-tools cache-lab-1 deploy-data-platform generate-dataset \
	load-dataset configure-dvc bootstrap-lab-1 verify-lab-1 incident-lab-1 \
	recover-lab-1 evidence-lab-1 test-lab-1

help:
	@printf '%s\n' \
	  'SupportOps AI platform — Lab 0 targets' \
	  '' \
	  '  make doctor                  Validate workstation prerequisites' \
	  '  make install-kind            Install the pinned kind binary locally' \
	  '  make cache-lab-0             Cache Lab 0 images and Helm chart' \
	  '  make create-cluster PROFILE=16gb|24gb|32gb' \
	  '  make install-ingress         Install pinned ingress-nginx' \
	  '  make build-platform-health   Build and push the baseline health image' \
	  '  make deploy-baseline         Apply namespaces and health service' \
	  '  make bootstrap-lab-0         Run the complete idempotent bootstrap' \
	  '  make verify-lab-0            Run automated acceptance checks' \
	  '  make incident-lab-0          Introduce the controlled outage' \
	  '  make recover-lab-0           Restore desired state and verify recovery' \
	  '  make evidence-lab-0          Capture text evidence under evidence/' \
	  '  make destroy-cluster         Delete only the Kind cluster' \
	  '  make destroy-all             Delete cluster, registry, and registry volume' \
	  '' \
	  'SupportOps AI platform — Lab 1 targets' \
	  '' \
	  '  make install-lab-1-tools     Install pinned DVC into .venv' \
	  '  make cache-lab-1             Cache SeaweedFS and PostgreSQL images' \
	  '  make deploy-data-platform    Deploy persistent object and relational stores' \
	  '  make generate-dataset        Generate and validate the 250-ticket release' \
	  '  make test-lab-1              Run deterministic dataset unit tests' \
	  '  make load-dataset            Load the release into PostgreSQL' \
	  '  make configure-dvc           Track and push the release through DVC' \
	  '  make bootstrap-lab-1         Run the complete Lab 1 workflow' \
	  '  make verify-lab-1            Run Lab 0 regression and Lab 1 checks' \
	  '  make incident-lab-1          Corrupt one dataset value intentionally' \
	  '  make recover-lab-1           Regenerate, reload, repush, and verify' \
	  '  make evidence-lab-1          Capture text evidence under evidence/'

doctor:
	@bash labs/lab-00/scripts/doctor.sh

install-kind:
	@bash labs/lab-00/scripts/install-kind.sh

cache-lab-0:
	@bash labs/lab-00/scripts/cache-dependencies.sh

create-cluster:
	@PROFILE=$(PROFILE) bash labs/lab-00/scripts/create-cluster.sh

install-ingress:
	@bash labs/lab-00/scripts/install-ingress.sh

build-platform-health:
	@bash labs/lab-00/scripts/build-platform-health.sh

deploy-baseline:
	@bash labs/lab-00/scripts/deploy-baseline.sh

bootstrap-lab-0: doctor cache-lab-0 create-cluster install-ingress build-platform-health deploy-baseline verify-lab-0

verify-lab-0:
	@bash verification/lab-00/verify.sh

incident-lab-0:
	@bash incident-packs/lab-00/baseline-outage.sh inject

recover-lab-0:
	@bash incident-packs/lab-00/baseline-outage.sh recover
	@bash verification/lab-00/verify.sh

evidence-lab-0:
	@bash labs/lab-00/scripts/capture-evidence.sh

install-lab-1-tools:
	@bash labs/lab-01/scripts/install-tools.sh

cache-lab-1:
	@bash labs/lab-01/scripts/cache-dependencies.sh

deploy-data-platform:
	@bash labs/lab-01/scripts/deploy-data-platform.sh

generate-dataset:
	@bash labs/lab-01/scripts/generate-dataset.sh

load-dataset:
	@bash labs/lab-01/scripts/load-dataset.sh

configure-dvc:
	@bash labs/lab-01/scripts/configure-dvc.sh

test-lab-1:
	@python3 -m unittest discover -s tests -p 'test_*.py' -v

bootstrap-lab-1: verify-lab-0 test-lab-1 install-lab-1-tools cache-lab-1 deploy-data-platform generate-dataset load-dataset configure-dvc verify-lab-1

verify-lab-1:
	@bash verification/lab-01/verify.sh

incident-lab-1:
	@bash incident-packs/lab-01/dataset-quality.sh inject
	@! python3 datasets/verify_supportops.py

recover-lab-1:
	@bash incident-packs/lab-01/dataset-quality.sh recover
	@bash labs/lab-01/scripts/load-dataset.sh
	@bash labs/lab-01/scripts/configure-dvc.sh
	@bash verification/lab-01/verify.sh

evidence-lab-1:
	@bash labs/lab-01/scripts/capture-evidence.sh

destroy-cluster:
	@bash labs/lab-00/scripts/destroy.sh cluster

destroy-all:
	@bash labs/lab-00/scripts/destroy.sh all
