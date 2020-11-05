## This file tries to explain the role of each file involved in Client Certificate authentication workflow


### CA-key.pem

Is the private key used to create a new CA cert that latter will be used to create each cert. This task will be done in LUA.

It was created with the command:

`openssl genrsa -des3 -out CA-key.pem -passout pass:1234 2048`

### CA-cert.pem

Is the CA certificate itself. It is referenced from the admin.conf nginx config file to validate the client certs with it.

It was created with the command:

`openssl req -new -key CA-key.pem -x509 -days 1000 -out CA-cert.pem -passin pass:1234`


### each-client.key

Its the unique private key each client has, it can be created async with all other files it will used to make every request from the client along with the client crt to sign the request.

It was created with this command:

`openssl genrsa -out each-client.key 2048`

### mydomain.com.csr

Is the sign request used to request a signed certificate from the CA.

It was created using this:

`openssl req -new -sha256 -key kong-iats-key.pem -subj "/C=US/ST=CA/O=Avature, Inc./CN=iats-sb0.local" -out iats-sb0.local.csr`

### mydomain.com.crt

It is the client certificate used to make every request from the client

It was created with the following command:

`openssl x509 -req -in mydomain.com.csr -CA CA-cert.pem -CAkey CA-key.pem -CAcreateserial -out mydomain.com.crt -days 500 -sha256 -passin pass:1234`

## Example call

This example call is just to know every data needed to make a secured call. We will use the PHP HTTP client Guzzle instead of curl command.

```
curl -X GET --insecure https://admin.kong-server.com/services/adminApi \
  --cert nginx/certs_for_client_auth/mydomain.com.crt\
  --key nginx/certs_for_client_auth/each-client.key\
  --header 'apikey: replace-this-string-with-your-api-key'\
  --header 'Content-Type: application/json'\
  --verbose
```
