require 'elasticsearch'

Rails.application.config.es_client = Elasticsearch::Client.new host: Settings.es_endpoint
