#!/bin/bash
set -eux

gnome-terminal --tab -t "Leshan server" -- java \
	-jar leshan-server-demo-2.0.0-SNAPSHOT-jar-with-dependencies.jar \
	-lp \
	55683 \
	-lh \
	localhost \
	-slp \
	55684 \
	-slh \
	localhost \
	-wp \
	9090 \
	-ks \
	device-certificate-scripts/leshan-server.p12 \
	-kst \
	pkcs12 \
	-ksp \
	password \
	-ksa \
	leshan-server \
	-keypass \
	password \
	-truststore \
	file://$(realpath device-certificate-scripts/leshan-server-trust-store.p12)#70617373776f7264#
