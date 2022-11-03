# frozen_string_literal: true

module ObsDeploy
  module CLI
    module Commands
      class RefreshRepositories < Dry::CLI::Command
        desc 'Refresh zypper repositories'
        option :user, type: :string, default: 'root', desc: 'User'
        option :host, type: :string, default: 'localhost', desc: 'Set the server address'
        option :port, type: :int, default: 22, desc: 'Set the server port'

        def call(user:, host:, port:, **)
          ssh_driver = ObsDeploy::SSH.new(user:, server: host, port:)
          zypper = ObsDeploy::Zypper.new
          ssh_driver.run(zypper.refresh)
        end
      end
    end
  end
end
