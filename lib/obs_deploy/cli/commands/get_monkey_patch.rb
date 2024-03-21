# frozen_string_literal: true

module ObsDeploy
  module CLI
    module Commands
      class GetMonkeyPatch < Dry::CLI::Command
        desc 'Get the monkey patch info of OBS, if any'
        option :user, type: :string, default: 'root', desc: 'User'
        option :host, type: :string, default: 'localhost', desc: 'Set the server address'
        option :port, type: :int, default: 22, desc: 'Set the server port'

        def call(user:, host:, port:, **)
          ssh_driver = ObsDeploy::SSH.new(user:, server: host, port:)
          ssh_driver.run(["cat /etc/motd | grep 'MONKEY PATCHES' -A 10"].to_s)
        end
      end
    end
  end
end
