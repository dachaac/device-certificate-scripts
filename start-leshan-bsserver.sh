#!/bin/bash
set -eux

gnome-terminal --tab -t "Leshan bootstrap server" -- java \
	-jar leshan-bsserver-demo-2.0.0-SNAPSHOT-jar-with-dependencies.jar \
	--coapport 5683 \
	--coapsport 5684 \
	--webport 8080 \
	-cert \
	device-certificate-scripts/leshan-bsserver-bundle.crt \
	-prik \
	device-certificate-scripts/leshan-bsserver-key.pkcs8.nopassword \
	-truststore \
	file://$(realpath device-certificate-scripts/leshan-bsserver-trust-store.p12)#70617373776f7264# \
	-est-server \
	https://localhost:8085/.well-known/est/ \
	-est-user \
	estuser \
	-est-pass \
	estpwd \
	-est-truststore \
	file://$(realpath device-certificate-scripts/leshan-bsserver-trust-store.p12)#70617373776f7264#
