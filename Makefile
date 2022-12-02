# Makefile
SHELL = /bin/bash

#Help
.PHONY: help
help:
	@echo "Commands:"
	@echo "push-version v=1.X                          : push images to GCP."
	@echo "turn-on-jlab                                : start jupyter server (requires ns=namespace)."
	@echo "jup-start ns=namespace version=1.X        : start jupyter server (requires v=version_number)."

	@echo "jup-rebuild ns=namespace version=1.X      : kill and rebuild (requires ns=namespace v=version_number)."

# AWS
.PHONY:
push-version:
	gcloud builds submit preprocess/. --region=us-central1 --tag us-central1-docker.pkg.dev/data-science-362714/time-to-failure/preprocess:$(v) && \
	gcloud builds submit train/. --region=us-central1 --tag us-central1-docker.pkg.dev/data-science-362714/time-to-failure/train:$(v) && \
	gcloud builds submit serve/. --region=us-central1 --tag us-central1-docker.pkg.dev/data-science-362714/time-to-failure/serve:$(v) && \
	gcloud builds submit monitor/. --region=us-central1 --tag us-central1-docker.pkg.dev/data-science-362714/time-to-failure/monitor:$(v) && \
	gcloud builds submit workstations/jupyter/. --region=us-central1 --tag us-central1-docker.pkg.dev/data-science-362714/time-to-failure/jupyter:$(v)

.PHONY:
jlab-on:
	kubectl create namespace jlab --dry-run=client -o yaml | kubectl apply -f - && \
	kubectl apply -f workstations/jupyter/deployment.yaml && \
	sleep 5 && \
	kubectl get pods -n jlab

.PHONY:
open-jlab:
	kubectl port-forward $(pod-name) 8888:8888 -n jlab

.PHONY:
jlab-off:
	kubectl delete namespaces jlab