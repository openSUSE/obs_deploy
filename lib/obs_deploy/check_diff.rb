# frozen_string_literal: true

module ObsDeploy
  class CheckDiff
    VERSION_REGEX = /.*\..*\..*\.(.*)-.*/
    INFO_PROVIDERS = [ObsDeploy::ApiInfo, ObsDeploy::SshInfo]

    def initialize(ssh_config, api_config)
      configs = [api_config, ssh_config]
      INFO_PROVIDERS.zip(configs).each do |provider, config|
        next unless provider.available?(**config)
        @provider = provider.new(**config)
        break
      end
    end

    def package_commit
      @provider.available_version
    end

    def obs_running_commit
      @provider.deployed_version
    end

    def github_diff
      Net::HTTP.get(URI("https://github.com/openSUSE/open-build-service/compare/#{obs_running_commit}...#{package_commit}.diff"))
    end

    def new_version_available?
      obs_running_commit != package_commit
    end

    def migration?
      return true if github_diff.nil? || github_diff.empty?

      GitDiffParser.parse(github_diff).files.any? { |f| f.match?(%r{db/migrate}) }
    end

    def data_migration?
      return true if github_diff.nil? || github_diff.empty?

      GitDiffParser.parse(github_diff).files.any? { |f| f.match?(%r{db/data}) }
    end

    def migrations
      return [] unless migration?

      GitDiffParser.parse(github_diff).files.select { |f| f =~ %r{db/migrate} }
    end
  end
end
