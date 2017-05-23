# k8s-deploy-env

This is a base image which contains:

* NodeJS 6 (the current version) and corresponding tooling (`npm`)
* Latest stable `kubectl` for interaction with Kubernetes Clusters
* Latest `az` (Azure Command Line 2.0)

You can build two flavors: Alpine ([`Dockerfile`](Dockerfile)) or Debian/Jessie ([`Dockerfile-debian`](Dockerfile-debian)), depending on which type of additional software you need inside derived images. In case you don't need additional software, or just Alpine based utilities, pick the Alpine image (default). If you need other software which needs a glibc/libpthreads based image, use `Dockerfile-debian`. The latter is slightly larger.

The Alpine image is available from the Docker Hub as `haufelexware/k8s-deploy-env:latest`; it's built once a week.

If you want to build your own (recommended!):

```bash
$ docker build --pull -t registry.yourcompany.io/project/k8s-deploy-env:latest .
...
$ docker push registry.yourcompany.io/project/k8s-deploy-env:latest
```

For the Debian image:

```bash
$ docker build --pull -f Dockerfile-debian -t registry.yourcompany.io/project/k8s-deploy-env:latest-debian .
...
$ docker push registry.yourcompany.io/project/k8s-deploy-env:latest-debian
```

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

## Using with volumes

In case you are not running your deployment image inside Jenkins using Docker-in-Docker (which is a standard way of using Docker with Jenkins nowadays), you may also just mount your scripts inside the container using docker volumes (`-v`) and override the command from the command line.

```
$ docker run -v `pwd`:/root/deploy registry.yourcompany.io/project/k8s-deploy-env:latest /root/deploy/deploy-kubernetes.sh
...
```

The previous version with deriving from the base image will always work though, also from inside Docker-in-Docker environments.
