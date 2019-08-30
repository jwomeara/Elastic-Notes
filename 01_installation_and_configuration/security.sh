# Enable elastic security on every node
xpack.security.enabled: true

# Configure transport layer security
## Generate a certificate and private key for each node in your cluster
./elasticsearch/bin/elasticsearch-certutil cert -out config/elastic-certificates.p12

## Copy the pkcs12 keystore to each node in your cluster

## Enable TLS on each node
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: elastic-certificates.p12
xpack.security.transport.ssl.truststore.path: elastic-certificates.p12

# Start your elasticsearch cluster, then
# set the passwords for all built-in users
./elasticsearch/bin/elasticsearch-setup-passwords interactive

# Configure kibana to have the correct user/pass (kibana.yaml)
elasticsearch.username: "kibana"
elasticsearch.password: "kibanapassword"

# OR create a keystore to avoid user/pass
bin/kibana-keystore create
bin/kibana-keystore add elasticsearch.username
kibana
bin/kibana-keystore add elasticsearch.password
kibanapassword
