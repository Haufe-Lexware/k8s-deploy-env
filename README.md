# k8s-deploy-env

This is a simple base image which contains:

* NodeJS 6 (currently 6.9.2) and corresponding tooling (`npm`)
* Latest stable `kubectl` (currently 1.4.6 or possibly 1.5.0) for interaction with Kubernetes Clusters
* the `nano` text editor

This base image is available from the Docker Hub as `haufelexware/k8s-deploy-env:latest`.

# Usage

The image is intended for use as base for deployment scripts in CI/CD pipelines where the build agents do not have a Node Runtime or a `kubectl` runtime. Typical usage would be to use the `docker build` process to deploy some artifact using `kubectl`.

**Example**: See also the [file in the examples folder](examples/Dockerfile-deploy).

```Dockerfile
FROM haufelexware/k8s-deploy-env:latest

COPY . /root/deploy
WORKDIR /root/deploy

ENTRYPOINT ["/root/deploy/deploy-kubernetes.sh"]
CMD ["", ""]
```

This `Dockerfile` assumes the following things:

* In the working dir (`.`), there are files (like `.kube/config`) which enable you to configure `kubectl`
* `deploy-kubernetes.sh` takes two parameters, e.g. `test latest` for "environment" and "branch/tag"

[Example of a `deploy-kubernetes.sh`](examples/deploy-kubernetes.sh) file, with the following assumptions:

* A file `kubeconfig` is assumed to reside in the working directory, which is copied to `~/.kube/config`
* There is a `service.yml.template` and a `deployment.yml.template` which contain environment variables which are replaces using a `perl` statement
* Both YAML files are deployed/configured on the k8s cluster using `kubectl apply -f <file.yml>` (first the service, then the deployment)

## Building your docker deployer

Build your image with

```bash
$ docker build -t yourtag -f Dockerfile-build .
````

Then run it like this:

```bash
$ docker run -it --rm yourtag <environment> <docker-tag>
```

If you need to pass in environment variables, either do that using the `-e` or `--env-file` parameter of the `docker run` command. These will then be available in the `deploy-kubernetes.sh` command.
