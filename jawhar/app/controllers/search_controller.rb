class SearchController < ApplicationController
    after_action :allow_cors, only: :search

    def search
        index = Index.first()
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
                query: {
                    bool: {
                        should: [
                        {
                            multi_match: {
                            query: q,
                            fields: [
                                'file.filename^4',
                                'content',
                                'path.real.fulltext^2',
                            ],
                            },
                        },
                        {
                            wildcard: {
                            'file.filename': {
                                value: "*#{query}*",
                                boost: 3,
                            },
                            },
                        },
                        ],
                    },
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

        es_response = Rails.application.config.es_client.search index: index.es_wildcard_name, body: query   
        hits = es_response["hits"]["hits"]
        hits = hits.map{ |h|
            h["_source"]["path"]["display"] = h["_source"]["path"]["real"].sub("/usr/share/hurracloud/jawhar/sources/", "")
            h
        }
        render json: { 
            total: es_response["hits"]["total"],
            hits: hits
        }
    end

    private
    def allow_cors
        response.headers['Access-Control-Allow-Origin'] = 'http://192.168.1.2:3000'
        response.headers['Access-Control-Allow-Methods'] = 'GET'
      end    

end
