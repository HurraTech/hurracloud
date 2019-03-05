class App < ApplicationRecord
    COMPOSE_TEMPLATE = IO.read(File.join(Rails.root, 'app', 'app-runner-compose-template.yml.erb'))
    enum status: [ :installed, :starting, :started, :stopping, :stopped ]


    def install
        return if self.status == "installed" ## Already installed            
        FileUtils.mkdir_p self.app_path

        self.deployment_port = rand(5001..6000)## TODO: Exclude already used ports
        File.write("#{self.app_path}/docker-compose.runner.yml", self.compose_file_contents)        
        #TODO: TEMP LOGIC UNTIL APP STORE SERVICE IS READY
        FileUtils.cp_r("/usr/share/hurracloud/jawhar/appStore-temp/#{self.app_unique_id}", "#{self.app_path}/CONTENT")
        ####
        self.status = :installed
        self.save()
        self.startApp()
    end

    def startApp
        self.status = :starting
        self.save()
        Resque.enqueue(Mounter, 'start_app', :app_id => self.id)    
    end

    def app_path
        "#{Settings.apps_path}/#{self.app_unique_id}"
    end

    def host_app_path
        "#{ENV['HOST_APPS_PATH']}/#{self.app_unique_id}"
    end

    def compose_file_contents
        app_unique_id = self.app_unique_id
        port_number = self.deployment_port
        host_app_path = self.host_app_path
        ERB.new(COMPOSE_TEMPLATE).result(binding)    
    end

end
