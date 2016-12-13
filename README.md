# k8s-deploy-env

This is a simple base image which contains:

* NodeJS 6 (currently 6.9.2) and corresponding tooling (`npm`)
* `kubectl` 1.4.9 for interaction with Kubernetes Clusters
* the `nano` text editor

This base image is available from the Docker Hub as `haufelexware/k8s-deploy-env:latest`.

# Usage

The image is intended for use as base for deployment scripts in CI/CD pipelines where the build agents do not have a Node Runtime or a `kubectl` runtime. Typical usage would be to use the `docker build` process to deploy some artifact using `kubectl`.

**Example**:

```Dockerfile
FROM haufelexware/k8s-deploy-env:latest

COPY . /root/deploy
RUN mkdir -p /root/.kube
COPY kubeconfig /root/.kube/config

WORKDIR /root/deploy

RUN ./deploy.sh

CMD "/bin/true"
```

This `Dockerfile` assumes the following things:

* There is a `kubeconfig` file in the current directory which is a `.kube/config` file containing the credentials and URLs to access the Kubernetes Cluster
* The `deploy.sh` file is used to deploy things onto the cluster; this may be any `bash` script leveraging `kubectl` to deploy/update things on the Kubernetes Cluster

Typically you would also put some `yml` definitions for Deployments and Services alongside these things, and they would automatically end up in your docker image due to the `COPY . /root/deploy` line.

