namespace :zahif do
    desc "Updates data sources"
    task :update => :environment do
        ZahifMounterWorker.perform_async('update_sources', {})
    end  
end

