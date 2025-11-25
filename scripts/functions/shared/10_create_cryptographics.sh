#!/usr/bin/env bash

# define variables
CERT_FILE="/tmp/cert.der"
KEY_FILE="/tmp/key.pem"
PKCS12_FILE="/tmp/key.p12"
CERT_PASSWORD="coreos"

# install needed utils
dnf install --best --allowerasing -y --skip-unavailable --nodocs --setopt=install_weak_deps=False \
    keyutils \
    nss-tools \
    pesign

# generate keys for secure boot
if [ ! -f "${CERT_FILE}" ] || [ ! -f "${KEY_FILE}" ]; then
  echo "Creating cryptographic material..."
  openssl req -new -x509 -newkey rsa:2048 -keyout "${KEY_FILE}" \
    -outform DER -out "${CERT_FILE}" -nodes -days 36500 \
    -subj "/CN=core-os/"
else
  echo "Using existing cryptographics..."
fi

# create PKCS FILE
openssl pkcs12 -export -out "${PKCS12_FILE}" -inkey "${KEY_FILE}" -in "${CERT_FILE}" \
  -passout pass:${CERT_PASSWORD}

# install keys for signing kernel and modules
certutil -A -i ${CERT_FILE} -n "MOK_CERT" -d /etc/pki/pesign -t "Pu,Pu,Pu"
pk12util -i ${PKCS12_FILE} -d /etc/pki/pesign -W ${CERT_PASSWORD}