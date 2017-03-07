FROM alpine:3.5

RUN apk add --no-cache alpine-sdk curl perl nodejs python python-dev py-pip build-base libffi-dev openssl-dev bash musl-dev openssh ca-certificates wget && \
    update-ca-certificates
RUN pip install --upgrade pip && \
    pip install ansible && \
    ansible-galaxy install geerlingguy.nfs && \
    pip install azure-cli
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

CMD ["/bin/true"]
