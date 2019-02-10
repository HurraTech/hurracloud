require 'resque-retry'

class MetadataUpdater
    extend Resque::Plugins::Retry
    @queue = :metadata_updates
    def self.perform(job, params)
      begin
        case job
        when 'index_paused'
            index_id = params['index_id']
            index = Index.find_by(id: index_id)  or return 
            index.status = :paused
            index.save()
        when 'index_cancelled'
            index_id = params['index_id']
            index = Index.find_by(id: index_id) or return
            index.destroy()
        end
      end
    end

  end
