# Device Certificate Demo CA

These scripts can be used to construct demo CA for playing out with Device Certificates.

Scripts supports creation of X.509 TLS Client Certificates and X.509 TLS Server Certificates.

## Manufacturer Demo CA

Manufacturer Demo CA is used to illustrate CA that would be in use by device manufacturer.
Manufacturer issues device certifcates for devices during manufacturing process.

Manufacturer Demo CA's issued device certificates are based on [IEEE 802.1AR-2018 - IEEE Standard for Local and Metropolitan Area Networks - Secure Device Identity](https://standards.ieee.org/standard/802_1AR-2018.html)'s IDevID's.

In order to create the Manufacturer Demo CA:

```
cd manufacturer-ca && ./create-manufacturer-ca.sh
```

In case there is a need to clean it up:
```
cd manufacturer-ca && ./cleanup.sh
```

## Service Demo CA

Service Demo CA is used to illustrate CA that would be in use by service provider.
Service provider would issue service specific device certificates for registered devices.
Service provider would in example utilize EST or SCEP or other protocols to issues service specific device certificates.

Service Demove CA's issued device certificates are giving example of using dev:urn:ops as a CN style device certificates.

In order to create the Service Demo CA:

```
cd service-ca && ./create-service-ca.sh
```

In case there is a need to clean it up:
```
cd service-ca && ./cleanup.sh
```
