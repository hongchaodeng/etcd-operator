#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

CSR_NAME=${POD_NAME}

# check if cert exist
# Only for peer certs

cat << EOD | cfssl genkey - | cfssljson -bare peer
{
  "hosts": [
    "${POD_IP}",
    "${POD_NAME}.${ETCD_CLUSTER_NAME}.default.svc"
  ],
  "CN": "${POD_NAME}",
  "key": {
    "algo": "rsa",
    "size": 2048
  }
}
EOD

# TODO: ownerRef
cat << EOD | kubectl create -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: ${CSR_NAME}
  labels:
    app: etcd
    etcd_cluster: ${ETCD_CLUSTER_NAME}
spec:
  groups:
  - system:authenticated
  request: $(cat peer.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
  - client auth
EOD

echo "waiting until CSR is approved..."
CSR_CERT=""
until [ -n "${CSR_CERT}" ]
do
    sleep 1
    CSR_CERT=$(kubectl get csr ${CSR_NAME} -o jsonpath='{.status.certificate}')
done

mkdir -p /etc/etcdtls/member/peer-tls/
(echo ${CSR_CERT} | base64 -d) >> /etc/etcdtls/member/peer-tls/peer.crt
mv peer-key.pem /etc/etcdtls/member/peer-tls/peer.key
# use cp instead of ln to avoid cross-device linking
cp /var/run/secrets/kubernetes.io/serviceaccount/ca.crt /etc/etcdtls/member/peer-tls/peer-ca.crt

echo "CSR has been approved ==="
