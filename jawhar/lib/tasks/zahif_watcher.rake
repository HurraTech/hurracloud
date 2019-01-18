namespace :zahif do
    desc "Updates data sources"
    task :update => :environment do
        Resque.enqueue(Mounter, 'update_sources')
    end  
end

