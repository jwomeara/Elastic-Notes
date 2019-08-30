# CRUD Operations

# Put a document with id 12345 in my_index, overwriting existing doc
# Note: Leave docId blank and POST to autogen an id
PUT my_index/_doc/12345
{
    "some": "doc"
}

# Put a document with id 12345 in my_index WITHOUT overwriting existing doc
PUT my_index/_create/12345
{
    "some": "doc"
}

# Update a field in a doc
POST my_index/_update/12345
{
    "doc": {
        "field": "value"
    }
}

# Delete a document from an index
DELETE my_index/_doc/12345

# Perform bulk CRUD Operations
POST my_index/_bulk
{"index" : {"_id":3}}
{"field1": "value1", "field2": "value2"}
{"update" : {"_id":5}}
{"doc": {"field1": "value1"}}
{"delete": {"_id":4}}

# Get a document from an index
GET my_index/_doc/12345

# Get multiple docs in a single request
GET _mget
{
    "docs": [
        {
            "_index": "index1",
            "_id": "id1"
        },
        {
            "_index": "index2",
            "_id": "id2"
        }
    ]
}

# Define a field alias
POST my_log_index/_mapping
{
  "properties": {
    "log": {
      "type": "object",
      "properties": {
        "level": {
          "type": "alias",
          "path": "log_level.keyword"
        }
      }
    }
  }
}

# Reindexing data
## Basic Example
POST _reindex
{
  "source": {
    "index": "my_index"
  },
  "dest": {
    "index": "my_new_index"
  }
}

## Reindex by query
POST _reindex
{
  "size": 100,
  "source": {
    "index": "my_index",
    "query": {
      "match": {
        "category": "Engineering"
      }
    }
  },
  "dest": {
    "index": "my_fixed_index"
  }
}

## Remote reindex
POST _reindex
{
  "source": {
    "index": "my_index",
    "remote": {
      "host": "http://some_remote_cluster:9200",
      "username": "USERNAME",
      "password": "PASSWORD"
    }
  },
  "dest": {
    "index": "my_local_index"
  }
}

## Reindex params
### Throttle the requests per second
POST _reindex?requests_per_second=500

### Parallelize the reindex task
POST _reindex?slices=5

# Update by query
## Basic example
POST my_blog_index/_update_by_query
{
  "query": {
    "match": {
      "category.keyword": ""
    }
  },
  "script": {
    "source": "ctx._source.category = \"None\""
  }
}

## Pick up where you left off
POST my_blog_index/_update_by_query
{
    "query": {
        "range": { "reindexBatch": { "lt": 1 } }
    },
    "script": {
        "source": "ctx._source.reindexBatch=1"
    }
}

# NOTE: To add a multi-field to an existing mapping
## First, update the mapping to add the multi-field
## Second, run update_by_query to populate the field

# Delete by query
POST my_blog_index/_delete_by_query
{
  "query": {
    "match": {
      "category.keyword": "some keyword"
    }
  }
}

# Ingest Pipelines

## Ingest pipeline processors
### set: sets a value in the document
### split: splits a value into an array

## Basic pipeline
PUT _ingest/pipeline/my_pipeline
{
  "processors": [
    {
      "set": {
        "field": "views",
        "value": 0
      }
    }
  ]
}

## Test your pipeline
POST _ingest/pipeline/my_pipeline/_simulate
{
  "docs": [
    {
      "_source": {
        "author": "Stephen King",
        "book": "The Shining"
      }
    }
  ]
}

## Index a doc using a pipeline
PUT my_index/_doc/1?pipeline=my_pipeline
{
    "author": "Stephen King",
    "category": "Horror"
}

## Reindex using a pipeling
POST _reindex
{
  "source": {
    "index": "my_index"
  },
  "dest": {
    "index": "new_index",
    "pipeline": "my_pipeline"
  }
}

## Assign a pipeline to an index
PUT test_index
{
    "settings": {
        "default_pipeline": "my_pipeline"
    }
}

## Create a pipeline that references other pipelines
PUT _ingest/pipeline/my_super_pipeline
{
  "processors": [
    {
      "pipeline": {
        "name": "my_pipeline"
      }
    },
    {
      "pipeline": {
        "name": "my_other_pipeline"
      }
    }
  ]
}   

# conditional set on ingest pipeline
PUT _ingest/pipeline/fix_genre
{
  "processors": [
    {
      "set": {
        "if": "ctx.genre.empty", 
        "field": "genre",
        "value": "horror"
      }
    },
    {
      "set": {
        "field": "reindexBatch",
        "value": 3
      }
    },
    {
      "split": {
        "field": "genre",
        "separator": ","
      }
    }
  ]
}

# Index Aliases
## Basic Index Alias
POST _aliases
{
  "actions": [
    {
      "add": {
        "index": "INDEX_NAME",
        "alias": "ALIAS_NAME"
      }
    },
    {
      "remove": {
        "index": "INDEX_NAME",
        "alias": "ALIAS_NAME"
      }
    }
  ]
}

## Index alias with a filter (convenient)
POST _aliases
{
  "actions": [
    {
      "add": {
        "index": "my_index_1",
        "alias": "my_index",
        "filter": {
          "match": {
            "category": "Horror"
          }
        }
      }
    }
  ]
}

# Index Templates
## Basic index template
PUT _template/my_index_template
{
  "index_patterns": "my_index-*",
  # lower order applied first, with increasing orders applied after
  "order": 1,
  "settings": {
    "number_of_shards": 4,
    "number_of_replicas": 1
  },
  "mappings": {
    "properties": {
      "@timestamp": {
        "type": "date"
      }
    }
  }
}

# Dynamic Indices
## Disable dynamic indices
PUT _cluster/settings
{
 "persistent": {
 "action.auto_create_index" : false
 }
}

## Whitelist certain dynamic indices
PUT _cluster/settings
{
 "persistent": {
 "action.auto_create_index" : ".monitoring-es*,logstash-*"
 }
}

# Whitelist x-pack indices
PUT _cluster/settings
{
  "persistent": {
    "action.auto_create_index": ".monitoring*,.watches,.triggered_watches,.watcher-history*,.ml*"
  }
}

# Dynamic templates
## type-based dynamic template
PUT my_index
{
  "mappings": {
    "dynamic_templates": [
      {
        "my_string_fields": {
          "match_mapping_type": "string",
          "mapping": {
            "type": "keyword"
          }
        }
      }
    ]
  }
}

## field name-based dynamic template
PUT my_index/_mapping
{
  "dynamic_templates": [
    {
      "my_float_fields": {
        "match": "f_*",
        "mapping": {
          "type": "float"
        }
      }
    }
  ]
}

# Adjust dynamic field control
PUT blogs/_mapping
{
  # No dynamic fields allowed, docs with undefined fields will not be indexed and will throw an error
  "dynamic": "strict"

  # Default value, which causes all undefined fields to be mapped dynamically
  "dynamic": "true"

  # No dynamic field mapping, but the doc will still be indexed
  "dynamic": "false"
}