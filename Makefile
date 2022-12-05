# Makefile
SHELL = /bin/bash

#Help
.PHONY: help
help:
	@echo "Commands:"
	@echo "push v=1.X      : push images to GCP."
	@echo "jlab-on         : start jupyter server"
	@echo "jlab-open       : port forwards jupyter to 127.0.0.0:8888 (requires pod name)"
	@echo "jlab-off        : turn off jupyter"

# AWS
.PHONY:
push:
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
jlab-open:
	kubectl port-forward $(p) 8888:8888 -n jlab

.PHONY:
jlab-off:
	kubectl delete namespaces jlab