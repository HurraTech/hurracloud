namespace :zahif_watcher do
    desc "Updates data sources"
    task :update_data_sources => :environment do
        ZahifMounterWorker.perform_async('update_sources', {})
    end  
end

