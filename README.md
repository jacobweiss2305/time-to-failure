# Predictive maintenance: time to failure

This is a guide that shows a model going from experiment to production using cloud native technologies.

Business problem: build a model that identifies machines who are at risk of failure.

## Key concepts:
- Cloud distributed ML
    - K8s
    - Containers
    - Argo
    - GCP
- Time to failure model
    - Survival Analysis (Lifelines)
- Distributed computing
    - Modin + Ray
- Monitoring
    - Streamlit
- Serving
    - FastAPI
- CI/CD
    - Github actions
    - Argo    

## Table of Contents
1. First time setup
    - Infrastructure
2. Develop model in Jupyter
    - Log experiments in MLFlow
3. Deployment
4. CI/CD

### 1. First time setup:

#### GKE

1. [Folllow install guide for gcloud](https://cloud.google.com/sdk/docs/install)

2. Set project config
    
    `gcloud conf set project $PROJECT_ID`

3. Install kubectl

    `gcloud components install kubectl`

4. Create cluster

    ```
    gcloud container clusters create \
    --machine-type n1-standard-2 \
    --num-nodes 2 \
    --zone us-central1-c \
    --cluster-version latest \
    cluster-1
    ```

    Optional, give your account permissions to perform all administrative actions needed.

    ```
    kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=your_email@email.com

    ```

5. Install GKE plug-in

    `gcloud components install gke-gcloud-auth-plugin`

#### Argo

6. Install Argo on GKE
    ```
    kubectl create namespace argo && \
    kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.4.3/install.yaml

    ```

7. Install Argo CLI
    ```
    # Download the binary
    curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v3.4.4/argo-linux-amd64.gz

    # Unzip
    gunzip argo-linux-amd64.gz

    # Make binary executable
    chmod +x argo-linux-amd64

    # Move binary to path
    mv ./argo-linux-amd64 /usr/local/bin/argo

    # Test installation 
    argo version

    # Test Argo workload
    argo submit -n argo --watch https://raw.githubusercontent.com/argoproj/argo-workflows/master/examples/hello-world.yaml
    ```

#### Artifact Registry

8. Create a repo to store our images

    ```
    gcloud artifacts repositories create time-to-failure \
        --project=$PROJECT_ID \
        --repository-format=docker \
        --location=$REGION \
        --description="Docker repository"
    ```

    When you are ready to push images use custom make command:
    `make push-version v:1.0`

#### Jupyter setup

9. Upload image in workstations/jupyter to Artifact Registry
    - This make command will push all images in the monitor, preprocess, serve, train, and jupyter folders.
    - To push just the:
    `gcloud builds submit workstations/jupyter/. --region=REGION--tag REGION-docker.pkg.dev/PROJECT_ID/ARTIFACT_REPO_NAME/jupyter:<add_tag>`

#### MLflow setup

10. 

