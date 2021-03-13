#!/bin/sh
echo "Creating Manufacturer's Products Root CA..."
mkdir manufacturer-root-ca
pwgen -s 24 1 > manufacturer-root-ca/manufacturer-root-ca.key.password
openssl ecparam -name secp384r1 -genkey | openssl ec -passout file:manufacturer-root-ca/manufacturer-root-ca.key.password -aes256 -out manufacturer-root-ca/manufacturer-root-ca.key
openssl req -new -config openssl.cnf -sha384 -nodes -subj "/C=FI/O=Manufacturer/CN=Products Root CA" -key manufacturer-root-ca/manufacturer-root-ca.key -passin file:manufacturer-root-ca/manufacturer-root-ca.key.password -out manufacturer-root-ca/manufacturer-root-ca.csr

touch manufacturer-root-ca/index.txt
echo 01 > manufacturer-root-ca/serial
echo 01 > manufacturer-root-ca/crlnumber

openssl ca -config openssl.cnf -name CA_root -extensions ext_root -keyfile manufacturer-root-ca/manufacturer-root-ca.key -passin file:manufacturer-root-ca/manufacturer-root-ca.key.password -selfsign -in manufacturer-root-ca/manufacturer-root-ca.csr -batch | openssl x509 -out manufacturer-root-ca/manufacturer-root-ca.crt -outform PEM

echo "Creating Manufacturer's Devices CA..."
mkdir manufacturer-devices-ca
pwgen -s 24 1 > manufacturer-devices-ca/manufacturer-devices-ca.key.password
openssl ecparam -name secp384r1 -genkey | openssl ec -passout file:manufacturer-devices-ca/manufacturer-devices-ca.key.password -aes256 -out manufacturer-devices-ca/manufacturer-devices-ca.key
openssl req -new -config openssl.cnf -sha384 -nodes -subj "/C=FI/O=Manufacturer/CN=Devices CA" -key manufacturer-devices-ca/manufacturer-devices-ca.key -passin file:manufacturer-devices-ca/manufacturer-devices-ca.key.password -out manufacturer-devices-ca/manufacturer-devices-ca.csr
touch manufacturer-devices-ca/index.txt
echo 01 > manufacturer-devices-ca/serial
echo 01 > manufacturer-devices-ca/crlnumber

openssl ca -config openssl.cnf -name CA_root -extensions ext_intermediate -keyfile manufacturer-root-ca/manufacturer-root-ca.key -passin file:manufacturer-root-ca/manufacturer-root-ca.key.password -cert manufacturer-root-ca/manufacturer-root-ca.crt -in manufacturer-devices-ca/manufacturer-devices-ca.csr -batch | openssl x509 -out manufacturer-devices-ca/manufacturer-devices-ca.crt -outform PEM

echo "Creating test device certificate - IDevID..."
pwgen -s 24 1 > IOTDEVICE-K1234567-IDevID.key.password
openssl ecparam -name prime256v1 -genkey | openssl ec -passout file:IOTDEVICE-K1234567-IDevID.key.password -aes256 -out IOTDEVICE-K1234567-IDevID.key
openssl req -new -config openssl.cnf -sha384 -nodes -subj "/C=FI/O=Manufacturer/CN=IoTDevice/serialNumber=K1234567" -key IOTDEVICE-K1234567-IDevID.key -passin file:IOTDEVICE-K1234567-IDevID.key.password -out IOTDEVICE-K1234567-IDevID.csr

openssl ca -config openssl.cnf -name CA_devices -extensions ext_client -keyfile manufacturer-devices-ca/manufacturer-devices-ca.key -passin file:manufacturer-devices-ca/manufacturer-devices-ca.key.password -cert manufacturer-devices-ca/manufacturer-devices-ca.crt -in IOTDEVICE-K1234567-IDevID.csr -batch | openssl x509 -out IOTDEVICE-K1234567-IDevID.crt -outform PEM

echo "Creating test device certificate - devurn..."
pwgen -s 24 1 > IOTDEVICE-K1234567-devurn.key.password
openssl ecparam -name prime256v1 -genkey | openssl ec -passout file:IOTDEVICE-K1234567-devurn.key.password -aes256 -out IOTDEVICE-K1234567-devurn.key
openssl req -new -config openssl.cnf -sha384 -nodes -subj "/C=FI/O=Manufacturer/CN=urn:dev:ops:32473-IoTDevice-K1234567" -key IOTDEVICE-K1234567-devurn.key -passin file:IOTDEVICE-K1234567-devurn.key.password -out IOTDEVICE-K1234567-devurn.csr

openssl ca -config openssl.cnf -name CA_devices -extensions ext_client -keyfile manufacturer-devices-ca/manufacturer-devices-ca.key -passin file:manufacturer-devices-ca/manufacturer-devices-ca.key.password -cert manufacturer-devices-ca/manufacturer-devices-ca.crt -in IOTDEVICE-K1234567-devurn.csr -batch | openssl x509 -out IOTDEVICE-K1234567-devurn.crt -outform PEM

echo "--- Manufacturer's Products Root CA Certificate ---"
openssl x509 -text -noout -in manufacturer-root-ca/manufacturer-root-ca.crt

echo

echo "--- Manufacturer's Devices CA CSR ---"
openssl req -text -noout -in manufacturer-devices-ca/manufacturer-devices-ca.csr

echo

echo "--- Manufacturer's Devices CA Certificate ---"
openssl x509 -text -noout -in manufacturer-devices-ca/manufacturer-devices-ca.crt

echo

echo "--- Device Certificate CSR - IDevID ---"
openssl req -text -noout -in IOTDEVICE-K1234567-IDevID.csr

echo

echo "--- Device Certificate - IDevID ---"
openssl x509 -text -noout -in IOTDEVICE-K1234567-IDevID.crt

echo

echo "--- Device Certificate CSR - devurn ---"
openssl req -text -noout -in IOTDEVICE-K1234567-devurn.csr

echo

echo "--- Device Certificate - devurn ---"
openssl x509 -text -noout -in IOTDEVICE-K1234567-devurn.crt

