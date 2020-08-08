require 'elasticsearch'

Rails.application.config.es_client = Elasticsearch::Client.new url: 'http://elasticsearch:9200'

Rails.application.config.es_client.indices.put_template(name: "defaults", body:
                                {
                                    "index_patterns": ["*"],
                                    "order": -1,
                                    "settings": {
                                        "number_of_shards": "1",
                                        "number_of_replicas": "0",
                                    }
                                })
