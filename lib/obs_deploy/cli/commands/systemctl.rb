# frozen_string_literal: true

module ObsDeploy
  module CLI
    module Commands
      class Systemctl < Dry::CLI::Command
        desc 'run systemd commands to verify application state'

        option :user, type: :string, default: 'root', desc: 'User'
        option :host, type: :string, default: 'localhost', desc: 'Set the server address'
        option :port, type: :int, default: 22, desc: 'Set the server port'

        def call(user:, host:, port:, **)
          ssh_driver = ObsDeploy::SSH.new(user:, server: host, port:)
          ssh_driver.run(ObsDeploy::Systemctl.new.status)
          ssh_driver.run(ObsDeploy::Systemctl.new.list_dependencies)
        end
      end
    end
  end
end
