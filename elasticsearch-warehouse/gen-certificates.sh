#!/bin/bash -x

export ALTNAME="DNS:${ES_INTERNAL_API_HOST},DNS:${ES_INTERNAL_API_HOST}.${NAMESPACE},DNS:${ES_INTERNAL_API_HOST}.${NAMESPACE}.svc.cluster.local"

# Root CA
openssl genrsa -out root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key root-ca-key.pem  -days 3650 -out root-ca.pem -config certs.cnf

# Admin cert
openssl genrsa -out admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out admin-key.pem
openssl req -new -key admin-key.pem -out admin.csr -config certs.cnf
openssl x509 -req -in admin.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -days 3650 -sha256 -out admin.pem -extfile certs.cnf

# Node cert
openssl genrsa -out node-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in node-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out node-key.pem
openssl req -new -key node-key.pem -out node.csr -config certs.cnf
openssl x509 -req -in node.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -days 3650 -sha256 -out node.pem -extfile certs.cnf

# Cleanup
rm admin-key-temp.pem
rm admin.csr
rm node-key-temp.pem
rm node.csr

