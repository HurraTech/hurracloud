class SearchController < ApplicationController
    def search
        q = params[:q] || ""
        from = (params[:from] || "0 ").to_i
        to = (params[:to] || "30").to_i
        if (q.strip() == '')
            query = {
                query: {
                    match_all: {},
                },
                sort: [{ 'file.created': { order: 'desc' } }],
                from: from,
                size: to - from + 1,
            };
        else
            query = {
                "query": {
                    "function_score": {
                      "query": {
                        "bool": {
                            "should": [{
                                "multi_match": {
                                  "query": q,
                                  "fields": [
                                      "file.filename^4",
                                      "content^2",
                                      "path.virtual^3"
                                  ]
                                }
                            },
                            {
                                "wildcard": {
                                "file.filename": {
                                    "value": "*#{q}*",
                                    "boost": 3
                                }
                                }
                            }]
                        }
                      },
                      "functions": [
                          {
                              "filter": { 
                                "terms": { 
                                  "file.extension": ["pdf", "doc", "docx"]
                                } 
                              },
                              "weight": 30
                          }
                      ]
                    }
                },
                sort: [{ _score: { order: 'desc' } }],
                from: from,
                size: to - from + 1,
                highlight: {
                    pre_tags: ['<em class="highlight">'],
                    post_tags: ['</em>'],
                    fragment_size: 0,
                    fields: {
                        content: {},
                    },
                },
            };
        end

        es_response = Rails.application.config.es_client.search index: "hurracloud_*", body: query   
        hits = es_response["hits"]["hits"]
        hits = hits.map{ |h|
            h["_source"]["path"] = h["_source"]["path"]["real"].sub("#{Settings.mounts_path}/", "")
            h
        }
        render json: { 
            total: es_response["hits"]["total"],
            hits: hits
        }
    end

end
