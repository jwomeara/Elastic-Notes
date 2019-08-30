# basic field types
## text
## keyword
## date
## date_nanos
## byte
## short
## integer
## long
## float
## double
## half_float
## scaled_float (useful for currency)
## boolean
## ip

# hierarchical types
## object
## nested

# special types
## geo_point
## geo_shape
## percolator
## range

# NOTE: Once defined, remapping existing fields is not possible

# Index mapping create example
PUT my_index
{
  "mappings": {
    "properties": {
      "@timestamp": {
        "type": "date"
      },
      "size": {
        "type": "long"
      },
      "coords": {
        "type": "geo_point"
      },
      "ip-address": {
        "type": "ip"
      },
      # example of an unindexed field
      "unindexed_field": {
        "type": "keyword",
        "index": false
      },
      # example of a non-aggregate field
      "non_aggregate_field": {
        "type": "keyword",
        "doc_values": false
      },
      # completely disable field (which is still returned in each doc)
      "disabled_field": {
        "type": "keyword",
        "enabled": false
      },
      # custom date format nanos example
      "last_viewed" : {
        "type": "date_nanos",
        "format": "strict_date_optional_time"
      },
      # custom daate format example
      "comment_time" : {
        "type": "date",
        "format" : "dd/MM/yyyy||epoch_millis"
      },
      # copy_to examples
      "region": {
        "type": "keyword",
        "copy_to": "locations"
      },
      "country": {
        "type": "keyword",
        "copy_to": "locations"
      },
      "city": {
        "type": "keyword",
        "copy_to": "locations"
      },
      # not part of _source, but IS indexed 
      "locations": {
        "type": "text"
      },
      # default value for 'nulls'
      "rating": {
        "type": "float",
        "null_value": 1.0
      },
      # disable coercion
      "rating_no_coerce": {
        "type": "long",
        "coerce": false
      }
    }
  }
}

# Index mapping update example
POST my_index/_mapping
{
    "properties": {
        "new_field": {
            "type": "text",
            "analyzer": "english"
        }
    }
}

# multi field mapping example
POST my_index
{
  "mappings": {
    "properties": {
      "country": {
        "type": "text",
        "fields": {
          "keyword": {
            "type": "keyword"
          }
        }
      }
    }
  }
}

# Use the analyze API to see how a term would be analyzed
GET _analyze
{
  "text": "Umma Gumma",
  "analyzer": "standard"
}

# dynamic templates
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

# Setup a nested mapping
# Note: Nested are intended to be used for arrays
PUT my_index
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text"
      },
      "authors": {
        "type": "nested",
        "properties": {
          "name": {
            "type": "text"
          },
          "publisher": {
            "type": "keyword"
          }
        }
      }
    }
  }
}  

# Analyzers
# Consist of 1) character filters, 2) tokenizer, 3) token filters
# Test what an analyzer will do to your text
GET _analyze
{
    "analyzer": "english",
    "text": "If it's ka it'll come like a wind"
} 

# Test a custom analyzer
POST _analyze
{
    "char_filter": []
    "tokenizer": "",
    "filters": [],
    "text": "analyze this text"
}

# Note: Before adding an analyzer to an existing index, it must first be closed

# specify an analyzer in your mapping
 "content": {
    "type": "text",
    "analyzer": "standard",
    "fields": {
        "english": {
            "type": "text",
            "analyzer": "english"
        }
    }
 }

# Create a custom analyzer for your index
PUT my_index
{
 "settings": {
    "analysis": {
        "char_filter": {
            "xstat_filter": {
                "type": "mapping",
                "mappings": ["X-Stat => XStat"]
            }
        },
        "analyzer": {
            "my_content_analyzer": {
                "type": "custom",
                "char_filter": ["xstat_filter"],
                "tokenizer": "standard",
                "filter": ["lowercase"]
            }
        }
    }
 }

# Another custom index analyzer
PUT my_index
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_analyzer": {
          "char_filter": [
            "my_char_filter"
          ],
          "tokenizer": "standard",
          "filter": ["lowercase", "stop", "my_stop"]
        }
      },
      "char_filter": {
        "my_char_filter": {
          "type": "mapping",
          "mappings": [
            "<tag> => tag"]
        }
      },
      "filter": {
        "my_stop": {
          "type": "stop",
          "stopwords": [
            "can",
            "are",
            "is",
            "the",
            "we",
            "you"
          ]
        }
      }
    }
  }
}

# multiple analyzers per index
PUT my_index
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_analyzer": {
          "char_filter": [
            "my_char_filter"
          ],
          "tokenizer": "standard",
          "filter": ["lowercase", "stop", "my_stop"]
        },
        "my_other_analyzer": {
            ...
        }
      },
      "char_filter": {
        "my_char_filter": {
          "type": "mapping",
          "mappings": [
            "<tag> => tag"]
        },
        "my_other_char_filter": {
            ...
        }
      },
      "filter": {
        "my_stop": {
          "type": "stop",
          "stopwords": [
            "can",
            "are",
            "is",
            "the",
            "we",
            "you"
          ]
        }
      },
      "my_other_token_filter": {
          ...
      }
    }
  }
}