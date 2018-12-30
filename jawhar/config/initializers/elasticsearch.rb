require 'elasticsearch'

Rails.application.config.es_client = Elasticsearch::Client.new url: 'http://192.168.1.2:9200'