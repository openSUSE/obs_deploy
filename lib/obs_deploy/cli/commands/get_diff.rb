# frozen_string_literal: true

module ObsDeploy
  module CLI
    module Commands
      class GetDiff < Dry::CLI::Command
        desc 'Get diff between deployed package and available package'
        option :url, type: :string, default: 'https://api.opensuse.org', desc: 'API url'
        option :package, type: :string, default: 'obs-api', desc: 'Package name'
        option :project, type: :string, default: 'OBS:Server:Unstable', desc: 'Project name'
        option :product, type: :string, default: ObsDeploy::DEFAULT_PRODUCT, desc: 'Product name'
        option :architecture, type: :string, default: 'x86_64', desc: 'Architecture'
        option :ignore_certificate, aliases: ['k'], type: :bool, default: false, desc: 'Ignore invalid or self-signed SSL certificates'

        def call(url:, product:, project:, ignore_certificate:, **)
          if ignore_certificate
            OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
            OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
          end
          puts "diff : #{ObsDeploy::CheckDiff.new(server: url, project: project, product: product).github_diff}"
        end
      end
    end
  end
end
