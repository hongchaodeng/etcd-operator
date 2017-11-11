FROM alpine

RUN apk add --no-cache bash curl

RUN curl -o /usr/local/bin/kubectl -L https://storage.googleapis.com/kubernetes-release/release/v1.8.2/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

RUN curl -o /usr/local/bin/cfssl -L https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 \
    && chmod +x /usr/local/bin/cfssl

RUN curl -o /usr/local/bin/cfssljson -L https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 \
    && chmod +x /usr/local/bin/cfssljson

ADD ./hack/build/etcdcsr/entry.sh /usr/local/bin/entry.sh
