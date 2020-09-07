require 'xmlsimple'
require 'yaml'
class App < ApplicationRecord
    COMPOSE_TEMPLATE = IO.read(File.join(Rails.root, 'app', 'app-runner-compose-template.yml.erb'))
    enum status: [ :installed, :starting, :started, :stopping, :stopped, :installing, :deleting ]
    # serialize :iconSvg, Hash
    serialize :state, Hash
    serialize :initCommands, Array
    has_many :app_commands, :dependent => :delete_all

    def install
        FileUtils.mkdir_p self.app_path

        self.deployment_port = rand(5001..6000)## TODO: Exclude already used ports
        self.proxy_port = rand(5001..6000)## TODO: Exclude already used ports
        File.open("#{self.app_path}/docker-compose.runner.yml", "w") do |f|
            f.write(self.compose_file_contents)
        end

        #TODO: TEMP LOGIC UNTIL APP STORE SERVICE IS READY
        if !File.symlink?("#{self.app_path}/CONTENT") #check if already exists
            FileUtils.ln_s("#{Settings.host_app_store_path}/#{self.app_unique_id}", "#{self.app_path}/CONTENT")
        end
        svg = (IO.read("/app/app-store/#{self.app_unique_id}/icon.svg"))
        metadata = YAML.load_file("/app/app-store/#{self.app_unique_id}/metadata.yml")
        self.iconSvg = svg.sub("<svg ", "<svg class=\"appIcon\" ");
        self.description = metadata["description"]
        self.name = metadata["name"]
        self.version = metadata["version"]
        self.initCommands = metadata["initCommands"]
        Rails.logger.info("ICON SVG is #{self.iconSvg}")

        ####
        self.status = :installed
        self.save()
        Mounter.init_app(:app_id => self.id)
    end

    def uninstall
        self.status = :deleting
        self.save()
        Mounter.delete_app(:app_id => self.id)
    end

    def exec(container, cmd, env)
        cmd = AppCommand.new(:command => cmd, :container => container, :environment => env, :status => :pending)
        cmd.app = self
        cmd.save()
        Mounter.exec_app(:cmd_id => cmd.id)
        cmd
    end

    def restart_container(container)
        Mounter.restart_container(:container => container, :app_id => self.id)
    end

    def stop_container(container)
        Mounter.stop_container(:container => container, :app_id => self.id)
    end

    def start_container(container)
        Mounter.start_container(:container => container, :app_id => self.id)
    end

    def startApp
        self.status = :starting
        self.save()
        Mounter.start_app(:app_id => self.id)
    end

    def app_path
        "#{Settings.apps_path}/#{self.app_unique_id}"
    end

    def host_app_path
        "#{ENV['HOST_APPS_PATH']}/#{self.app_unique_id}"
    end

    def compose_file_contents
        compose_tpl = IO.read(File.join(Rails.root, 'app', 'app-runner-compose-template.yml.erb'))
        ##TODO: change above to constant

        app_unique_id = self.app_unique_id
        port_number = self.deployment_port
        proxy_port_number = self.proxy_port
        host_app_path = self.host_app_path
        hostname = Settings.hostname
        ERB.new(compose_tpl).result(binding)
    end

end
