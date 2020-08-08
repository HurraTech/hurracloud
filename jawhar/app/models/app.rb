require 'xmlsimple'
require 'yaml'
class App < ApplicationRecord
    COMPOSE_TEMPLATE = IO.read(File.join(Rails.root, 'app', 'app-runner-compose-template.yml.erb'))
    enum status: [ :installed, :starting, :started, :stopping, :stopped ]
    serialize :iconSvg, Hash
    serialize :state, Hash
    serialize :initCommands, Array

    def install

        FileUtils.mkdir_p self.app_path

        self.deployment_port = rand(5001..6000)## TODO: Exclude already used ports
        File.open("#{self.app_path}/docker-compose.runner.yml", "w") do |f|
            f.write(self.compose_file_contents)
        end

        #TODO: TEMP LOGIC UNTIL APP STORE SERVICE IS READY
        # FileUtils.cp_r("/usr/share/hurracloud/jawhar/appStore-temp/#{self.app_unique_id}", "#{self.app_path}/CONTENT")
        if !File.symlink?("#{self.app_path}/CONTENT") #check if already exists
            FileUtils.ln_s("#{Settings.host_app_store_path}/#{self.app_unique_id}", "#{self.app_path}/CONTENT")
        end
        svg = (IO.read("/usr/share/hurracloud/jawhar/appStore-temp/#{self.app_unique_id}/icon.svg"))
        metadata = YAML.load_file("/usr/share/hurracloud/jawhar/appStore-temp/#{self.app_unique_id}/metadata.yml")
        self.iconSvg = XmlSimple.xml_in(svg, KeepRoot: false, SuppressEmpty: true, KeyToSymbol: false, ForceArray: true)
        self.description = metadata["description"]
        self.name = metadata["name"]
        self.version = metadata["version"]
        self.initCommands = metadata["initCommands"]
        Rails.logger.info("ICON SVG is #{self.iconSvg}")

        ####
        self.status = :installed
        self.save()
        Resque.enqueue(Mounter, 'init_app', :app_id => self.id)
    end

    def exec(container, cmd, env)
        cmd = AppCommand.new(:command => cmd, :container => container, :environment => env, :status => :pending)
        cmd.app = self
        cmd.save()
        Resque.enqueue(Mounter, 'exec_app', :cmd_id => cmd.id)
        cmd
    end

    def restart_container(container)
        Resque.enqueue(Mounter, 'restart_container', :container => container, :app_id => self.id)
    end

    def stop_container(container)
        Resque.enqueue(Mounter, 'stop_container', :container => container, :app_id => self.id)
    end

    def start_container(container)
        Resque.enqueue(Mounter, 'start_container', :container => container, :app_id => self.id)
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
        compose_tpl = IO.read(File.join(Rails.root, 'app', 'app-runner-compose-template.yml.erb'))
        ##TODO: change above to constant

        app_unique_id = self.app_unique_id
        port_number = self.deployment_port
        host_app_path = self.host_app_path
        ERB.new(compose_tpl).result(binding)
    end

end
