#!/bin/sh
echo "Creating Codesign Root CA..."
mkdir codesign-root-ca
pwgen -s 24 1 > codesign-root-ca/codesign-root-ca.key.password
openssl ecparam -name secp384r1 -genkey | openssl ec -passout file:codesign-root-ca/codesign-root-ca.key.password -aes256 -out codesign-root-ca/codesign-root-ca.key
openssl req -new -config openssl.cnf -sha256 -nodes -subj "/C=FI/CN=Manufacturer Codesign Root CA" -key codesign-root-ca/codesign-root-ca.key -passin file:codesign-root-ca/codesign-root-ca.key.password -out codesign-root-ca/codesign-root-ca.csr

touch codesign-root-ca/index.txt
echo 01 > codesign-root-ca/serial
echo 01 > codesign-root-ca/crlnumber

openssl ca -config openssl.cnf -name CA_root -extensions ext_root -keyfile codesign-root-ca/codesign-root-ca.key -passin file:codesign-root-ca/codesign-root-ca.key.password -selfsign -in codesign-root-ca/codesign-root-ca.csr -batch | openssl x509 -out codesign-root-ca/codesign-root-ca.crt -outform PEM

echo "Creating MyProduct Codesign Certificate..."
pwgen -s 24 1 > MyProduct.key.password
openssl ecparam -name prime256v1 -genkey | openssl ec -passout file:MyProduct.key.password -aes256 -out MyProduct.key
openssl req -new -config openssl.cnf -sha256 -nodes -subj "/CN=MyProduct" -key MyProduct.key -passin file:MyProduct.key.password -out MyProduct.csr

openssl ca -config openssl.cnf -name CA_root -extensions ext_codesign -keyfile codesign-root-ca/codesign-root-ca.key -passin file:codesign-root-ca/codesign-root-ca.key.password -cert codesign-root-ca/codesign-root-ca.crt -in MyProduct.csr -batch | openssl x509 -out MyProduct.crt -outform PEM

echo "--- Codesign Root CA Certificate ---"
openssl x509 -text -noout -in codesign-root-ca/codesign-root-ca.crt

echo

echo "--- MyProduct Codesign Certificate CSR ---"
openssl req -text -noout -in MyProduct.csr

echo

echo "--- MyProduct Codesign Certificate ---"
openssl x509 -text -noout -in MyProduct.crt
