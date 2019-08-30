# Run elastic search as daemon and save pid
./bin/elasticsearch -d -p pid.txt

# Define config options via cmd line
./bin/elasticsearch -E path.data=/data/elasticsearch

# Set java opts via cmd line
ES_JAVA_OPTS="-Xms512m" ./bin/elasticsearch

# Default node name is the hostname.  Override by setting
./bin/elasticsearch -E node.name=my_node_name

# Define a name for your cluster
./bin/elasticsearch -E cluster.name=my_cluster


# Elasticsearch network configuration
## HTTP Configuration (e.g. REST APIs)
### specify the bind and publish host
http.host: _local_/_site_/_global_
### the port to bind to
http.port: ####

## Transport Configuration (e.g. internal comms.)
### specify the bind and publish host
transport.host: _local_/_site_/_global_
### the port to bind to
transport.tcp.port: ####

## Discovery and seed host providers
discovery.seed_hosts: ["server1", "server2", "server3"]
### or
discover.seed_providers: filename

# Cluster state and health
GET _cluster/state

# alternatively, use cat
GET _cat/nodes?v

# Define initial master nodes
# Note: this must be defined on each master-eligible node
cluster.initial_master_nodes: ["node1", "node2", "node3"]

# Node Roles
node.master: true
node.data: true
node.ingest: true
node.ml: true
