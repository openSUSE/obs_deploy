# frozen_string_literal: true

module ObsDeploy
  module CLI
    module Commands
      class GetPackageVersion < Dry::CLI::Command
        desc 'Get the available package version'
        option :url, type: :string, default: 'https://api.opensuse.org', desc: 'API url'
        option :package, type: :string, default: 'obs-api', desc: 'Package name'
        option :product, type: :string, default: '15.3', desc: 'Product name'
        option :architecture, type: :string, default: 'x86_64', desc: 'Architecture'
        option :ignore_certificate, aliases: ['k'], type: :bool, default: false, desc: 'Ignore invalid or self-signed SSL certificates'

        def call(url:, ignore_certificate:, product:, **)
          if ignore_certificate
            OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
            OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
          end

          puts "Available package: #{ObsDeploy::CheckDiff.new(server: url, product: product).package_version}"
        end
      end
    end
  end
end
