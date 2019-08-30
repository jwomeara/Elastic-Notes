# Search and count
GET my_index/_search
{

}

GET my_index/_count
{

}


# Query Types
# match
# match_phrase
# multi_match
# range
# bool (must, must_not, should, filter)
# terms
# geo_distance
# nested
# regexp
# wildcard
# exists

# Note: Use field.keyword (if available) to match on the exact contents of the field, and ignore text analysis
# Note: Query results are sorted by _score descending by default

# Match examples
## Match (OR)
GET my_index/_search
{
    "query": {
        "match": {
            "field": "value"
        }
    }
}

## Match (AND)
GET my_index/_search
{
    "query": {
        "match": {
            "field": {
                "query": "value",
                "operator": "and"
            }
        }
    }
}

## Match (minimum number of terms that should match)
GET my_index/_search
{
    "query": {
        "match": {
            "field": {
                "query": "value",
                "minimum_should_match": 2
            }
        }
    }
}

## Match (with fuzziness)
GET my_index/_search
{
    "query": {
        "match": {
            "field": {
                "query": "value",
                "fuzziness": 1
            }
        }
    }
}

## Match (with auto fuzziness)
GET my_index/_search
{
    "query": {
        "match": {
            "field": {
                "query": "value",
                "fuzziness": "auto"
            }
        }
    }
}

## Match (with includes/excludes)
GET my_index/_search
{
    "query": {
        "match": {
            "field": {
                "query": "value"
            }
        }
    },
    "_source": {
        "includes": ["field1", "field2"],
        "excludes": ["field3", "field4" ]
    }
}

# Match Phrase examples
## Match Phrase
GET my_index/_search
{
    "query": {
        "match_phrase": {
            "content": "all work and no play"
        }
    }
}

## Match Phrase (with slop)
### Slop represents how far apart terms are allowed to be
GET my_index/_search
{
    "query": {
        "match_phrase": {
            "content": {
                "query":"all work and no play",
                "slop": 1
            }
        }
    }
}

# Multi match example
## multi match
GET my_index/_search
{
    "query": {
        "multi_match": {
            "query": "Stephen King",
            "fields": [
                "title",
                "content",
                "author"
            ],
            "type": "best_fields"
            # "type": "most_fields"
            # "type": "phrase"
        }
    }
}

## Multi match (with boost)
GET my_index/_search
{
    "query": {
        "multi_match": {
            "query": "Stephen King",
            "fields": [
                "title^2",
                "content",
                "author"
            ],
            "type": "best_fields"
        }
    }
}

## Multi match (phrase with boost)
GET my_index/_search
{
    "query": {
        "multi_match": {
            "query": "Stephen King",
            "fields": [
                "title^2",
                "content",
                "author"
            ],
            "type": "phrase"
        }
    }
}

# Range examples
# Explicit date range
GET my_index/_search
{
    "query": {
        "range": {
            "publish_date": {
                "gte": "2017-12-01",
                "lt": "2018-01-01"
            }
        }
    }
}

# Date range using date math
GET my_index/_search
{
    "query": {
        "range": {
            "publish_date": {
                "gte": "now-3M"
            }
        }
    }
}

# Bool queries
## Basic Bool
GET my_index/_search
{
    "query": {
    "bool": {
        // affects hits and score
        "must": [
            {}
            ],
        // affects hits, not score
        "must_not": [
            {}
            ],
        // affects score, not hits
        "should": [
            {}
            ],
        // affects hits, not score (caches)
        "filter": [
            {}
            ]
        }
    }
}

## must match elastic, increase score for docs containing stack/query/speed, and at least 1 should match
GET my_index/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "title": "The Shining"
          }
        }
      ],
      "should": [
        {
          "match": {
            "title": "book"
          }
        },
        {
          "match": {
            "title": "story"
          }
        },
        {
          "match": {
            "title": "article"
          }
        }
      ],
      "minimum_should_match": 1
    }
  }
}

## Filter with date range
GET my_index/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "content": "all work and no play"
          }
        }
      ],
      "filter": {
        "range": {
          "publish_date": {
            "gte": "2017-12-01",
            "lt": "2018-01-01"
          }
        }
      }
    }
  }
}

## Filter with date range (using date math)
GET my_index/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "content": "all work and no play"
          }
        }
      ],
      "filter": [
        {
          "range": {
            "publish_date": {
              "gte": "now-3M"
            }
          }
        }
      ]
    }
  }
}

# Terms query example
## Simple example (operates as OR)
GET my_index/_search

{
    "query": {
        "terms": {
            "category.keyword": [
                "Horror",
                "Thriller"
            ]
        }
    }
}

# geo distance query example
## Simple example
GET my_index/_search
{
  "query": {
    "geo_distance": {
      "distance": "200km",
      "coordinates": {
        "lat": 30,
        "lon": -87
      }
    }
  }
}

# Pagination
## First query
GET my_index/_search
{
    "from": 0,
    "size": 10,
    "query": {
        "match": {
            "field": "value"
        }
    }
}

## Next query
GET my_index/_search
{
    "from": 10
    "size": 10,
    "query": {
        "match": {
            "field": "value"
        }
    }
}

# Highlighting
GET my_index/_search
{
    "query": {
        "match": {
            "field": "value"
        }
    },
    "highlight": {
        "fields": {
            "field1": {}
        },
        "pre_tags": ["<tag>"],
        "post_tags": ["</tag>"]
    }
}

# Query a nested object
GET my_index/_search
{
  "query": {
    "nested": {
      "path": "authors",
      "query": {
        "bool": {
          "must": [
            {
              "match": {
                "authors.name": "stephen"
              }
            },
            {
              "match": {
                "authors.company": "penguin"
              }
            }
          ]
        }
      }
    }
  }
}

# Script-fields example
# Note: Scripts cannot run against text fields, only keyword
GET my_index*/_search
{
  # include this part to get ALL of the field
  "_source": [],
  "query": {
    "bool": {
      "filter": [
        {
          "exists": {
            "field": "geoip.city.keyword"
          }
        },
        {
          "exists": {
            "field": "geoip.region.keyword"
          }
        }
      ]
    }
  },
  "script_fields": {
    "city_state": {
      "script": {
        "source": """
        doc['geoip.city.keyword'].value + "," + doc['geoip.region.keyword'].value
        """,
        "lang": "painless"
      }
    }
  }
}

# Use execute API to test a script
POST _scripts/painless/_execute
{
  "script": {
    "source": "doc['author.keyword'].getValue().length() <= 8"
  },
  "context": "filter",
  "context_setup": {
    "index": "blogs",
    "document": {
      "author": "Stephen King"
    }
  }
}

# Scripted query which modifies the score
GET my_index/_search
{
    "query": {
        "script_score": {
            "query": {
                "match": {
                    "content": "all work and no play"
                }
            },
            "script": {
                "source": "_score * Math.log(doc['views'].value)"
            }
        }
    }
}

# Scripted query example
GET my_index/_search
{
    "query": {
        "bool": {
            "filter": {
                "script": {
                    "script": {
                        "source": "doc['locales'].size() > 1"
                    }
                }
            }
        }
    }
}

# Search Templates
## Basic Search Template
POST _scripts/my_search_template
{
  "script": {
    "lang": "mustache",
    "source": {
      "query": {
        "match": {
          "{{my_field}}": "{{my_value}}"
        }
      }
    }
  }
}

## Use the search template
GET my_index/_search/template
{
  "id": "my_search_template",
  "params": {
    "my_field": "title",
    "my_value": "The Shining"
  }
}

## Mustache conditionals
{{#param1}}
 "This section is skipped if param1 is null or false"
{{/param1}}

## Search template using conditionals
POST _scripts/books_with_date_search
{
  "script": {
    "lang": "mustache",
    "source": """
    {
        "query": {
            "bool": {
                "must": {
                    "match": {"content": "{{search_term}}"}
                }
                {{#search_date}}
                ,
                "filter": {
                    "range": {
                        "publish_date": {"gte": "{{search_date}}"}
                    }
                }
                {{/search_date}}
            }
        }
    }
"""
  }
}

## Use the conditional search template
GET my_index/_search/template
{
  "id": "books_with_date_search",
  "params": {
    "search_term": "stephen king",
    "search_date": "1980-01-01"
  }
}

# Cross cluster search
# First, add a remote cluster
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

### {cluster_name}:{index_name}
GET other_cluster:my_index/_search
{
  "query": {
    "match": {
      "title": "the shining"
    }
  }
}

# Search local and remote
GET my_local_index,other_cluster:my_index/_search
{
  "query": {
    "match": {
      "title": "the shining"
    }
  }
}

# Scroll API
## Initial query
GET my_index*/_search?scroll=1m
{
  "size": 10
}


## Subsequent queries
GET _search/scroll
{
  "scroll": "1m",
  "scroll_id": "{{scroll_id}}"
}

# Delete a scroll
DELETE _search/scroll
{
  "scroll_id": "DnF1ZXJ5VGhlbkZldGNoBAAAAAAAAAMSFlBTQ0Q1YUk0U0JPQzBpbmF6SUg5VVEAAAAAAAADFBZQU0NENWFJNFNCT0MwaW5heklIOVVRAAAAAAAAAxMWUFNDRDVhSTRTQk9DMGluYXpJSDlVUQAAAAAAAAMfFkxrZUFEVE1EVGNLdjZDRzhiODVRZmc"
}

# Delete all scrolls
DELETE _search/scroll/_all