namespace :zahif do
    desc "Updates data sources"
    task :update => :environment do
        Resque.enqueue(Mounter, 'update_sources')
    end  

    desc "Request to index indiviual file"
    task :index_file, [:file] => :environment do |task, args|
        Resque.enqueue(SingleFileIndexer, 'index_file', :file => args[:file])
    end
end

