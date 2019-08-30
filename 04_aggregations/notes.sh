# Basic Aggregation syntax
GET my_index/_search
{
  "aggs": {
    "my_aggregation": {
      "AGG_TYPE": {
          ...
      }
    }
  }
}

# Note: Remember to set size to 0 to save on data transfer time
# Note: Add a query term to limit the scope of the aggregation

# Types of aggregations
# sum
# min
# max
# avg
# stats
# cardinality
# percentiles (use 50 for median)
# percentile_ranks (opposite of percentiles)
# top_hits
# significant_text
# significant_terms (used for keyword fields)
# date_histogram (bucket agg, sortable)
# histogram (bucket agg, sortable)
# range (bucket agg)
# terms (bucket agg, sortable)
# nested aggregations

# Basic Aggregations

## sum/min/max/avg/stats/cardinality example
GET my_index*/_search
{
  "aggs": {
    "my_sum": {
      "sum": {
          "field": "the_field"
      }
    }
  }
}

# Disable caching during aggregation
GET my_index/_search?request_cache=false
{
  "aggs": {
    "my_sum": {
      "sum": {
          "field": "the_field"
      }
    }
  }
}

## percentiles example
GET my_index*/_search
{
  "aggs": {
    "my_percentiles": {
      "percentiles": {
          "field": "the_field",
          "percents": [
              25,
              50,
              75,
              100   
          ]
      }
    }
  }
}

## percentile_ranks example
GET my_index*/_search
{
  "aggs": {
    "percentile_ranks_agg": {
      "percentile_ranks": {
        "field": "the_field",
        "values": [
          40,
          50,
          60
        ]
      }
    }
  }
}

## top_hits example
GET my_index*/_search
{
  "query": {
    ...
  },
  "aggs": {
    "my_index_top_hits": {
      "top_hits": {
        "size": 5
      }
    }
  }
}

## significant_text example
GET my_index*/_search
{
  "aggs": {
    "significant_text_agg": {
      "significant_text": {
        "field": "the_field",
        "size": 10
      }
    }
  }
}

## significant_text example
GET my_index*/_search
{
  "aggs": {
    "significant_terms_agg": {
      "significant_terms": {
        "field": "the_field.keyword",
        "size": 10
      }
    }
  }
}

## date_histogram example
GET my_index*/_search
{
  "size": 0,
  "aggs": {
    "messages_by_day": {
      "date_histogram": {
        "field": "@timestamp",
        "interval": "day",
        # sortable
        "order": {
            "_key": "desc"
        }
      }
    }
  }
}

## histogram example
GET my_index*/_search
{
  "size": 0,
  "aggs": {
    "runtime_histogram": {
      "histogram": {
        "field": "runtime_ms",
        "interval": 100,
        # don't include terms with docs less than this
        "minimum_doc_count": 1000
        # sortable
        "order": {
            "_key": "desc"
        }
      }
    }
  }
}

## range example
GET my_index*/_search
{
  "size": 0,
  "aggs": {
    "runtime_breakdown": {
      "range": {
        "field": "runtime_ms",
        "ranges": [
          {
            "from": 0,
            "to": 20
          },
          {
            "from": 20,
            "to": 50
          },
          {
            "from": 50
          }
        ]
      }
    }
  }
}

## terms example
GET my_index*/_search
{
  "size": 0,
  "aggs": {
    "country_names": {
      "terms": {
        "field": ".country.keyword",
        "size": 5,
        # sortable
        "order": {
            "_key": "desc"
        }
      }
    }
  }
}

# Combined Aggregations

## Bytes per day
GET my_index*/_search
{
  "size": 0,
  "aggs": {
    "requests_per_day": {
      "date_histogram": {
        "field": "@timestamp",
        "interval": "day"
      },
      "aggs": {
        "bytes_per_day": {
          "sum": {
            "field": "size"
          }
        }
      }
    }
  }
}

## Multiple aggs per bucket
GET my_index*/_search
{
  "size": 0,
  "aggs": {
    "requests_per_day": {
      "date_histogram": {
        "field": "@timestamp",
        "interval": "day"
      },
      "aggs": {
        "bytes_per_day": {
          "sum": {
            "field": "size"
          }
        },
        "median_runtime": {
          "percentiles": {
            "field": "runtime_ms",
            "percents": [
              50
            ]
          }
        }
      }
    }
  }
} 

# Nested aggregation example
GET my_index*/_search
{
  "size": 0,
  "aggs": {
    "nested_authors": {
      "nested": {
        "path": "authors"
      },
      "aggs": {
        "publishers": {
          "terms": {
            "field": "authors.publisher.keyword"
          },
          "aggs": {
            "authors": {
              "terms": {
                "field": "authors.name.keyword"
              }
            }
          }
        }
      }
    }
  }
}

# Perform a scripted aggregation
GET my_index/_search
{
  "size": 0,
  "aggs": {
    "books_by_day_of_week": {
      "terms": {
        "script": {
          "source": "doc['publish_date'].value.getMonth()"
        }
      }
    }
  }
}

# multi-level scripted aggregation
GET my_index/_search
{
  "size": 0,
  "aggs": {
    "books_by_year": {
      "terms": {
        "script": {
          "source": "doc['publish_date'].value.getYear()"
        }
      },
      "aggs": {
        "books_by_month": {
          "terms": {
            "script": {
              "source": "doc['publish_date'].value.getMonth()"
            }
          }
        }
      }
    }
  }
}