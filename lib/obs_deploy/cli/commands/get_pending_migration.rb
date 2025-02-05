# frozen_string_literal: true

require 'openssl'
module ObsDeploy
  module CLI
    module Commands
      class GetPendingMigration < Dry::CLI::Command
        option :url, type: :string, default: 'https://api.opensuse.org', desc: 'where the packages are available to be installed'
        option :targeturl, type: :string, default: 'https://api.opensuse.org', desc: 'where we actually want to deploy '
        option :ignore_certificate, aliases: ['k'], type: :boolean, default: false, desc: 'Ignore invalid or self-signed SSL certificates'

        # FIXME: Refactor this method
        # rubocop:disable Metrics/MethodLength
        def call(url:, targeturl:, ignore_certificate:, **)
          if ignore_certificate
            OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
            OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
          end

          migrations = ObsDeploy::CheckDiff.new(server: url, target_server: targeturl).migrations

          if migrations.empty?
            puts 'No pending migrations'
            exit(0)
          else
            puts migrations
            exit(1)
          end
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
