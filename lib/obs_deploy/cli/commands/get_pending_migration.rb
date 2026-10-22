# frozen_string_literal: true

module ObsDeploy
  module CLI
    module Commands
      class GetPendingMigration < Dry::CLI::Command
        desc 'Get the pending migrations'

        option :user, type: :string, default: ObsDeploy::DEFAULT_USER, desc: 'User'
        option :host, type: :string, default: ObsDeploy::DEFAULT_HOST, desc: 'Set the server address'
        option :port, type: :int, default: ObsDeploy::DEFAULT_PORT, desc: 'Set the server port'
        option :url, type: :string, default: ObsDeploy::DEFAULT_URL, desc: 'API url'
        option :package, type: :string, default: ObsDeploy::DEFAULT_PACKAGE, desc: 'Package name'
        option :source_package, type: :string, default: ObsDeploy::DEFAULT_SOURCE_PACKAGE, desc: 'Source package name'
        option :project, type: :string, default: ObsDeploy::DEFAULT_PROJECT, desc: 'Project name'
        option :product, type: :string, default: ObsDeploy::DEFAULT_PRODUCT, desc: 'Product name'
        option :architecture, type: :string, default: ObsDeploy::DEFAULT_ARCHITECTURE, desc: 'Architecture'
        option :ignore_certificate, aliases: ['k'], type: :bool, default: false, desc: 'Ignore invalid or self-signed SSL certificates'

        # FIXME: Refactor this method
        # rubocop:disable-next Metrics/MethodLength
        def call(user:, host:, port:, url:, package:, project:, product:, architecture:, ignore_certificate:, **)
          migrations = ObsDeploy::CheckDiff.new({user:, host:, port:}, {url:, package:, project:, product:, architecture:, ignore_certificate:}).migrations

          if migrations.empty?
            puts 'No pending migrations'
            exit(0)
          else
            puts migrations
            exit(1)
          end
        end
      end
    end
  end
end
