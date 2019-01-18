require 'elasticsearch'

Rails.application.config.es_client = Elasticsearch::Client.new url: 'http://192.168.1.2:9200'

Rails.application.config.es_client.indices.put_template(name: "defaults", body:  
                                {
                                    "index_patterns": ["*"],
                                    "order": -1,
                                    "settings": {
                                        "number_of_shards": "1",
                                        "number_of_replicas": "0",
                                        "index": {
                                            "blocks": {
                                                "read_only_allow_delete": "false"
                                            }
                                        }
                                    }
                                })
