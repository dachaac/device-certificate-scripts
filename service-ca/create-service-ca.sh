#!/bin/sh
echo "Creating Service Root CA..."
mkdir service-root-ca
pwgen -s 24 1 > service-root-ca/service-root-ca.key.password
openssl ecparam -name secp521r1 -genkey | openssl ec -passout file:service-root-ca/service-root-ca.key.password -aes256 -out service-root-ca/service-root-ca.key
openssl req -new -config openssl.cnf -sha256 -nodes -subj "/C=FI/O=Service/CN=Service Root CA" -key service-root-ca/service-root-ca.key -passin file:service-root-ca/service-root-ca.key.password -out service-root-ca/service-root-ca.csr

touch service-root-ca/index.txt
echo 01 > service-root-ca/serial
echo 01 > service-root-ca/crlnumber

openssl ca -config openssl.cnf -name CA_root -extensions ext_root -keyfile service-root-ca/service-root-ca.key -passin file:service-root-ca/service-root-ca.key.password -selfsign -in service-root-ca/service-root-ca.csr -batch | openssl x509 -out service-root-ca/service-root-ca.crt -outform PEM

echo "Creating Service Devices CA..."
mkdir service-devices-ca
pwgen -s 24 1 > service-devices-ca/service-devices-ca.key.password
openssl ecparam -name secp384r1 -genkey | openssl ec -passout file:service-devices-ca/service-devices-ca.key.password -aes256 -out service-devices-ca/service-devices-ca.key
openssl req -new -config openssl.cnf -sha256 -nodes -subj "/C=FI/O=Service/CN=Devices CA" -key service-devices-ca/service-devices-ca.key -passin file:service-devices-ca/service-devices-ca.key.password -out service-devices-ca/service-devices-ca.csr
touch service-devices-ca/index.txt
echo 01 > service-devices-ca/serial
echo 01 > service-devices-ca/crlnumber

openssl ca -config openssl.cnf -name CA_root -extensions ext_intermediate -keyfile service-root-ca/service-root-ca.key -passin file:service-root-ca/service-root-ca.key.password -cert service-root-ca/service-root-ca.crt -in service-devices-ca/service-devices-ca.csr -batch | openssl x509 -out service-devices-ca/service-devices-ca.crt -outform PEM

echo "Creating Service Servers CA..."
mkdir service-servers-ca
pwgen -s 24 1 > service-servers-ca/service-servers-ca.key.password
openssl ecparam -name secp384r1 -genkey | openssl ec -passout file:service-servers-ca/service-servers-ca.key.password -aes256 -out service-servers-ca/service-servers-ca.key
openssl req -new -config openssl.cnf -sha256 -nodes -days 23360 -subj "/C=FI/O=Service/CN=Servers CA" -key service-servers-ca/service-servers-ca.key -passin file:service-servers-ca/service-servers-ca.key.password -out service-servers-ca/service-servers-ca.csr
touch service-servers-ca/index.txt
echo 01 > service-servers-ca/serial
echo 01 > service-servers-ca/crlnumber

openssl ca -config openssl.cnf -name CA_root -extensions ext_intermediate -keyfile service-root-ca/service-root-ca.key -passin file:service-root-ca/service-root-ca.key.password -cert service-root-ca/service-root-ca.crt -in service-servers-ca/service-servers-ca.csr -batch | openssl x509 -out service-servers-ca/service-servers-ca.crt -outform PEM

echo "Creating test device certificate..."
pwgen -s 24 1 > IOTDEVICE-K1234567.key.password
openssl ecparam -name prime256v1 -genkey | openssl ec -passout file:IOTDEVICE-K1234567.key.password -aes256 -out IOTDEVICE-K1234567.key
openssl req -new -config openssl.cnf -sha256 -nodes -subj "/CN=urn:dev:ops:32473-IoT_Device-K1234567" -key IOTDEVICE-K1234567.key -passin file:IOTDEVICE-K1234567.key.password -out IOTDEVICE-K1234567.csr

openssl ca -config openssl.cnf -name CA_devices -extensions ext_client -keyfile service-devices-ca/service-devices-ca.key -passin file:service-devices-ca/service-devices-ca.key.password -cert service-devices-ca/service-devices-ca.crt -in IOTDEVICE-K1234567.csr -batch | openssl x509 -out IOTDEVICE-K1234567.crt -outform PEM

echo "Creating localhost Server Certificate..."
pwgen -s 24 1 > localhost.key.password
openssl ecparam -name prime256v1 -genkey | openssl ec -passout file:localhost.key.password -aes256 -out localhost.key
openssl req -new -config openssl.cnf -sha256 -nodes -days 23360 -subj "/C=FI/O=Service/CN=localhost" -addext "subjectAltName = DNS:localhost" -key localhost.key -passin file:localhost.key.password -out localhost.csr

openssl ca -config openssl.cnf -name CA_servers -extensions ext_server -keyfile service-servers-ca/service-servers-ca.key -passin file:service-servers-ca/service-servers-ca.key.password -cert service-servers-ca/service-servers-ca.crt -in localhost.csr -batch | openssl x509 -out localhost.crt -outform PEM

echo "--- Service Root CA Certificate ---"
openssl x509 -text -noout -in service-root-ca/service-root-ca.crt

echo

echo "--- Service's Devices CA CSR ---"
openssl req -text -noout -in service-devices-ca/service-devices-ca.csr

echo

echo "--- Service's Devices CA Certificate ---"
openssl x509 -text -noout -in service-devices-ca/service-devices-ca.crt

echo

echo "--- Service's Servers CA CSR ---"
openssl req -text -noout -in service-servers-ca/service-servers-ca.csr

echo

echo "--- Service's Servers CA Certificate ---"
openssl x509 -text -noout -in service-servers-ca/service-servers-ca.crt

echo

echo "--- Device Certificate CSR ---"
openssl req -text -noout -in IOTDEVICE-K1234567.csr

echo

echo "--- Device Certificate ---"
openssl x509 -text -noout -in IOTDEVICE-K1234567.crt

echo

echo "--- Localhost Server Certificate CSR ---"
openssl req -text -noout -in localhost.csr

echo

echo "--- Localhost Server Certificate ---"
openssl x509 -text -noout -in localhost.crt
