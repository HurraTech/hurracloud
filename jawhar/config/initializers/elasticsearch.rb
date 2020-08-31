require 'elasticsearch'

Rails.application.config.es_client = Elasticsearch::Client.new host: ENV['ES_ENDPOINT']

Rails.application.config.es_client.indices.put_template(name: "defaults", body:
                                {
                                    "index_patterns": ["*"],
                                    "order": -1,
                                    "settings": {
                                        "number_of_shards": "1",
                                        "number_of_replicas": "0",
                                    }
                                })
