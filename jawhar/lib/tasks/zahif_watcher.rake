namespace :zahif do
    desc "Updates data sources"
    task :update => :environment do
        Resque.enqueue(Mounter, 'update_sources')
    end  

    desc "Request to index indiviual file"
    task :index_file, [:file] => :environment do |task, args|
        puts "GOING TO INDEX #{args[:file]}"
    end
end

