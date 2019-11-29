#!/bin/bash

set -eux

cp service-ca/localhost.key leshan-server-key.pem
cp service-ca/localhost.key.password leshan-server-key.password
cp service-ca/localhost.crt leshan-server.crt
cat service-ca/localhost.crt service-ca/service-servers-ca/service-servers-ca.crt > leshan-server-bundle.crt

cp service-ca/localhost.key leshan-bsserver-key.pem
cp service-ca/localhost.key.password leshan-bsserver-key.password
cp service-ca/localhost.crt leshan-bsserver.crt
cat service-ca/localhost.crt service-ca/service-servers-ca/service-servers-ca.crt > leshan-bsserver-bundle.crt

cp manufacturer-ca/IOTDEVICE-K1234567-IDevID.csr leshan-client-initial-IDevID.csr
cp manufacturer-ca/IOTDEVICE-K1234567-IDevID.crt leshan-client-initial-IDevID.crt
cat manufacturer-ca/IOTDEVICE-K1234567-IDevID.crt manufacturer-ca/manufacturer-devices-ca/manufacturer-devices-ca.crt > leshan-client-initial-IDevID-bundle.crt
cp manufacturer-ca/IOTDEVICE-K1234567-IDevID.key leshan-client-initial-IDevID.key
cp manufacturer-ca/IOTDEVICE-K1234567-IDevID.key.password leshan-client-initial-IDevID.key.password

cp manufacturer-ca/IOTDEVICE-K1234567-devurn.csr leshan-client-initial-devurn.csr
cp manufacturer-ca/IOTDEVICE-K1234567-devurn.crt leshan-client-initial-devurn.crt
cat manufacturer-ca/IOTDEVICE-K1234567-devurn.crt manufacturer-ca/manufacturer-devices-ca/manufacturer-devices-ca.crt > leshan-client-initial-devurn-bundle.crt
cp manufacturer-ca/IOTDEVICE-K1234567-devurn.key leshan-client-initial-devurn.key
cp manufacturer-ca/IOTDEVICE-K1234567-devurn.key.password leshan-client-initial-devurn.key.password

cp service-ca/IOTDEVICE-K1234567.csr leshan-client-service.csr
cp service-ca/IOTDEVICE-K1234567.crt leshan-client-service.crt
cat service-ca/IOTDEVICE-K1234567.crt service-ca/service-devices-ca/service-devices-ca.crt > leshan-client-service-bundle.crt
cp service-ca/IOTDEVICE-K1234567.key leshan-client-service.key
cp service-ca/IOTDEVICE-K1234567.key.password leshan-client-service.key.password

mkdir -p est-ca

test -f est-ca/server-cacerts.pem || \
	cat \
		service-ca/service-root-ca/service-root-ca.crt \
		service-ca/service-devices-ca/service-devices-ca.crt \
	> est-ca/cacerts.pem

if [ ! -f est-ca/openssl.cnf ] ; then
	cp service-ca/openssl.cnf est-ca/openssl.cnf
        sed "s#default_ca      = CA_root#default_ca      = CA_devices#" -i est-ca/openssl.cnf
        sed "s#\[ CA_devices \]#\[ CA_devices \]\ncertificate      = service-devices-ca/service-devices-ca.crt\nprivate_key      = service-devices-ca/service-devices-ca.key.nopassword\nunique_subject = no\nx509_extensions = ext_client#" -i est-ca/openssl.cnf
fi

if [ ! -d est-ca/service-devices-ca ] ; then
	cp -a service-ca/service-devices-ca est-ca/
	echo "unique_subject = no" > est-ca/service-devices-ca/index.txt.attr
fi

test -f est-ca/service-devices-ca/service-devices-ca.key.nopassword || \
openssl ec \
	-passin file:est-ca/service-devices-ca/service-devices-ca.key.password \
	-in est-ca/service-devices-ca/service-devices-ca.key \
	-out est-ca/service-devices-ca/service-devices-ca.key.nopassword

test -f leshan-client-initial-IDevID.csr.der || \
openssl req \
	-in leshan-client-initial-IDevID.csr \
	-outform DER \
	-out leshan-client-initial-IDevID.csr.der

test -f leshan-client-initial-devurn.csr.der || \
openssl req \
	-in leshan-client-initial-devurn.csr \
	-outform DER \
	-out leshan-client-initial-devurn.csr.der

test -f leshan-client-service.csr.der || \
openssl req \
	-in leshan-client-service.csr \
	-outform DER \
	-out leshan-client-service.csr.der

test -f leshan-server-key.pkcs8 || \
openssl pkcs8 \
	-topk8 \
	-inform PEM \
	-in leshan-server-key.pem \
	-passin file:leshan-server-key.password \
	-outform DER \
	-out leshan-server-key.pkcs8 \
	-nocrypt

test -f leshan-server-key.pem.nopassword || \
openssl ec \
	-passin file:leshan-server-key.password \
	-in leshan-server-key.pem \
	-out leshan-server-key.pem.nopassword

test -f leshan-server.p12 || \
openssl pkcs12 \
	-inkey leshan-server-key.pem \
	-passin file:leshan-server-key.password \
	-in leshan-server-bundle.crt \
	-export \
	-name leshan-server \
	-password pass:password \
	-out leshan-server.p12

test -f leshan-server.der.hex || \
openssl x509 \
	-in leshan-server.crt \
	-inform PEM \
	-outform DER | xxd -p -c 1024 > leshan-server.der.hex

test -f leshan-bsserver-key.pkcs8 || \
openssl pkcs8 \
	-topk8 \
	-inform PEM \
	-in leshan-bsserver-key.pem \
	-passin file:leshan-bsserver-key.password \
	-outform DER \
	-out leshan-bsserver-key.pkcs8 \
	-nocrypt

test -f leshan-bsserver.p12 || \
openssl pkcs12 \
	-inkey leshan-bsserver-key.pem \
	-passin file:leshan-bsserver-key.password \
	-in leshan-bsserver-bundle.crt \
	-export \
	-name leshan-bsserver \
	-password pass:password \
	-out leshan-bsserver.p12

test -f leshan-bsserver-key.pkcs8.nopassword || \
openssl pkcs8 \
        -topk8 \
        -inform PEM \
        -outform DER \
        -nocrypt \
        -in leshan-bsserver-key.pem \
        -passin file:leshan-bsserver-key.password \
        -out leshan-bsserver-key.pkcs8.nopassword


test -d credentials || \
mkdir credentials

test -f credentials/bsserver_cert.der || \
openssl x509 -inform PEM -in leshan-bsserver.crt -outform DER -out credentials/bsserver_cert.der

test -f credentials/bsserver_privkey.der || \
cp leshan-bsserver-key.pkcs8 credentials/bsserver_privkey.der

echo
echo "### Creating Leshan servers Trust Store ###"
echo

if ! test -f leshan-server-trust-store.p12 ; then
keytool \
	-import \
	-noprompt \
	-trustcacerts \
	-keystore leshan-server-trust-store.p12 \
	-storetype pkcs12 \
	-storepass password \
	-alias "Manufacturer's Root CA" \
	-file manufacturer-ca/manufacturer-root-ca/manufacturer-root-ca.crt

keytool \
	-import \
	-noprompt \
	-trustcacerts \
	-keystore leshan-server-trust-store.p12 \
	-storetype pkcs12 \
	-storepass password \
	-alias "Service's Root CA" \
	-file service-ca/service-root-ca/service-root-ca.crt

keytool \
	-list \
	-keystore leshan-server-trust-store.p12 \
	-storepass password \
	-v
fi

if ! test -f leshan-server-trust-store.pem ; then
	cat \
		manufacturer-ca/manufacturer-devices-ca/manufacturer-devices-ca.crt \
		manufacturer-ca/manufacturer-root-ca/manufacturer-root-ca.crt \
		service-ca/service-root-ca/service-root-ca.crt \
		> leshan-server-trust-store.pem
fi

echo
echo "### Creating Leshan bootstrap servers Trust Store ###"
echo

if ! test -f leshan-bsserver-trust-store.p12 ; then
keytool \
	-import \
	-noprompt \
	-trustcacerts \
	-keystore leshan-bsserver-trust-store.p12 \
	-storetype pkcs12 \
	-storepass password \
	-alias "Manufacturer's Root CA" \
	-file manufacturer-ca/manufacturer-root-ca/manufacturer-root-ca.crt

keytool \
	-import \
	-noprompt \
	-trustcacerts \
	-keystore leshan-bsserver-trust-store.p12 \
	-storetype pkcs12 \
	-storepass password \
	-alias "Service's Root CA" \
	-file service-ca/service-root-ca/service-root-ca.crt

keytool \
	-list \
	-keystore leshan-bsserver-trust-store.p12 \
	-storepass password \
	-v
fi

if ! test -d leshan-bsserver-trust-store ; then
	mkdir -p leshan-bsserver-trust-store
	cp manufacturer-ca/manufacturer-root-ca/manufacturer-root-ca.crt leshan-bsserver-trust-store/
	cp service-ca/service-root-ca/service-root-ca.crt leshan-bsserver-trust-store/
fi

echo
echo "### Creating Leshan client Trust Store ###"
echo

if ! test -f leshan-client-trust-store.p12 ; then
keytool \
	-import \
	-noprompt \
	-trustcacerts \
	-keystore leshan-client-trust-store.p12 \
	-storetype pkcs12 \
	-storepass password \
	-alias "Service's Root CA" \
	-file service-ca/service-root-ca/service-root-ca.crt

keytool \
	-import \
	-noprompt \
	-trustcacerts \
	-keystore leshan-client-trust-store.p12 \
	-storetype pkcs12 \
	-storepass password \
	-alias "Service's Servers CA" \
	-file service-ca/service-servers-ca/service-servers-ca.crt

keytool \
	-list \
	-keystore leshan-client-trust-store.p12 \
	-storepass password \
	-v
fi

test -f leshan-client-initial-IDevID.pkcs8 || \
openssl pkcs8 \
	-topk8 \
	-inform PEM \
	-in leshan-client-initial-IDevID.key \
	-passin file:leshan-client-initial-IDevID.key.password \
	-outform DER \
	-out leshan-client-initial-IDevID.pkcs8 \
	-nocrypt

openssl pkcs12 \
	-inkey leshan-client-initial-IDevID.key \
	-passin file:leshan-client-initial-IDevID.key.password \
	-in leshan-client-initial-IDevID-bundle.crt \
	-export \
	-name leshan-client-initial-IDevID \
	-password pass:password \
	-out leshan-client-initial-IDevID.p12

test -f leshan-client-initial-devurn.pkcs8 || \
openssl pkcs8 \
	-topk8 \
	-inform PEM \
	-in leshan-client-initial-devurn.key \
	-passin file:leshan-client-initial-devurn.key.password \
	-outform DER \
	-out leshan-client-initial-devurn.pkcs8 \
	-nocrypt

openssl pkcs12 \
	-inkey leshan-client-initial-devurn.key \
	-passin file:leshan-client-initial-devurn.key.password \
	-in leshan-client-initial-devurn-bundle.crt \
	-export \
	-name leshan-client-initial-devurn \
	-password pass:password \
	-out leshan-client-initial-devurn.p12

test -f leshan-client-initial-IDevID.pkcs8.nopassword || \
openssl pkcs8 \
	-topk8 \
	-inform PEM \
	-outform DER \
	-nocrypt \
	-in leshan-client-initial-IDevID.key \
	-passin file:leshan-client-initial-IDevID.key.password \
	-out leshan-client-initial-IDevID.pkcs8.nopassword

test -f leshan-client-initial-IDevID.der.hex || \
openssl x509 \
        -in leshan-client-initial-IDevID.crt \
        -inform PEM \
        -outform DER | xxd -p -c 4096 > leshan-client-initial-IDevID.der.hex

test -f leshan-client-initial-IDevID.pkcs8.hex || \
cat leshan-client-initial-IDevID.pkcs8.nopassword | xxd -p -c 4096 > leshan-client-initial-IDevID.pkcs8.hex

test -f leshan-client-initial-devurn.pkcs8.nopassword || \
openssl pkcs8 \
	-topk8 \
	-inform PEM \
	-outform DER \
	-nocrypt \
	-in leshan-client-initial-devurn.key \
	-passin file:leshan-client-initial-devurn.key.password \
	-out leshan-client-initial-devurn.pkcs8.nopassword

test -f leshan-client-initial-devurn.der.hex || \
openssl x509 \
        -in leshan-client-initial-devurn.crt \
        -inform PEM \
        -outform DER | xxd -p -c 4096 > leshan-client-initial-devurn.der.hex

test -f leshan-client-initial-devurn.pkcs8.hex || \
cat leshan-client-initial-devurn.pkcs8.nopassword | xxd -p -c 4096 > leshan-client-initial-devurn.pkcs8.hex

test -f leshan-client-service.pkcs8.nopassword || \
openssl pkcs8 \
	-topk8 \
	-inform PEM \
	-outform DER \
	-nocrypt \
	-in leshan-client-service.key \
	-passin file:leshan-client-service.key.password \
	-out leshan-client-service.pkcs8.nopassword

test -f leshan-client-service.der.hex || \
openssl x509 \
        -in leshan-client-service.crt \
        -inform PEM \
        -outform DER | xxd -p -c 4096 > leshan-client-service.der.hex

test -f leshan-client-service.pkcs8.hex || \
cat leshan-client-service.pkcs8.nopassword | xxd -p -c 4096 > leshan-client-service.pkcs8.hex
