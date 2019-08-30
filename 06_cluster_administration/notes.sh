# Create an index and specify the number of shards/replicas
PUT my_index
{
    "settings": {
        "number_of_shards": 3,
        "number_of_replicas": 2
    }
}

# Set the refresh interval for an index
PUT my_index/_settings
{
    "refresh_interval": "30s"
}

# determine whether to refresh on doc ingest
## block until next refresh
PUT my_index/_doc/551?refresh=wait_for
{
    "title": "The Dark Tower",
    "category": "SciFi",
    ...
}

## don't force a refresh
PUT my_index/_doc/551?refresh=false
{
    "title": "Cujo",
    "category": "Horror",
    ...
}

## force a refresh
PUT my_index/_doc/551?refresh=true
{
    "title": "The Stand",
    "category": "Horror",
    ...
}

# cluster indices health
GET _cluster/health?level=indices

# health of an index
GET _cluster/health/my_index

# shard health
GET _cluster/health?level=shards

# find unallocated shards
GET _cluster/allocation/explain

# investigate health using health endpoint
GET _cluster/health?level=indices
GET _cluster/health/test4?level=shards

# investigate health using cat
GET _cat/indices?v
GET _cat/shards/test4?v

# Backup and restore a cluster

## Create a backup repo
## NOTE: You must add 'path.repo: /mnt/my_repo_folder' to elasticsearch.yml for each node in the cluster
PUT _snapshot/my_repo
{
  "type": "fs",
  "settings": {
    "location": "/mnt/my_repo_folder",
    # Optional settings
    "compress": true,
    "max_restore_bytes_per_sec": "40mb",
    "max_snapshot_bytes_per_sec": "40mb"
  }
}

# Perform a backup
## Backup everything
PUT _snapshot/my_repo/my_index_snapshot_1

## Backup specific indices
PUT _snapshot/my_repo/my_index_snapshot_1
{
 "indices": "lmy_index-*",
 "ignore_unavailable": true,
 "include_global_state": true
}

## Check status of backup
GET _snapshot/my_repo/my_index_snapshot_1/status

## Check and wait for completion
GET _snapshot/my_repo/my_index_snapshot_1/status?wait_for_completion=true

## Get info about a snapshot
GET _snapshot/my_repo/_all # all snapshots
GET _snapshot/my_repo/my_index_snapshot_1 # specific snapshot

## Delete a snapshot
DELETE _snapshot/my_repo/my_index_snapshot_1

# Perform a restore
## Restore everything
POST _snapshot/my_repo/my_index_snapshot_2/_restore

## Restore specific indices
POST _snapshot/my_repo/my_index_snapshot_2/_restore
 "indices": "my_index-*",
 "ignore_unavailable": true,
 "include_global_state": false
 # Rename restored indices
 "rename_pattern": "my_index-(.+)",
 "rename_replacement": "restored-my-index-$1"
}

# NOTE: Snapshots can be restored to other clusters if they share the same repo

# Node Attributes and Shard Allocation
## Set an attribute on a node in elasticsearch.yml
node.attr.my_rack: rack1

# NOTE: All cluster settings are 
## 1) transient - won't survive a restart
## 2) permanent - will survive a restart

# Configure cluster to force shards to be split between rack1 and rack2
PUT _cluster/settings
{
  "transient": {
    "cluster": {
      "routing": {
        "allocation.awareness.attributes": "my_rack",
        "allocation.awareness.force.my_rack.values": "rack1,rack2"
      }
    }
  }
}

# Remote cluster configuration
## Add a remote cluster
PUT _cluster/settings
{
  "persistent": {
    "cluster.remote": {
      "other_cluster": {
        "seeds": [
          "other_cluster:9300",
          "12.34.56.78:9300"
        ]
      }
    }
  }
}

# Hot Warm Architecture (falls under shard allocation)
# First, apply labels to your nodes in elasticsearch.yml
node.attr.my_temp: hot
node.attr.my_temp: warm
node.attr.my_server: small
node.attr.my_server: medium

# Next, tell your index which nodes it can/can't run on
PUT some_index
{
    "settings": {
        "index.routing.allocation.require.my_temp": "hot",
        "index.routing.allocation.include.my_temp": "warm",
        "index.routing.allocation.exclude.my_temp": "small"
    }
}
