#!/bin/bash
set -eux

gnome-terminal --tab -t "Leshan client" -- java \
	-jar leshan-client-demo-2.0.0-SNAPSHOT-jar-with-dependencies.jar \
	-b \
	-u \
	localhost \
	-scert \
	device-certificate-scripts/leshan-bsserver.crt \
	-n \
	urn:dev:ops:32473-IoT_Device-K1234567 \
	-ccert \
	device-certificate-scripts/leshan-client-initial-devurn-bundle.crt \
	-cprik \
	device-certificate-scripts/leshan-client-initial-devurn.pkcs8.nopassword \
	-truststore \
	file://$(realpath device-certificate-scripts/leshan-client-trust-store.p12)#70617373776f7264#
