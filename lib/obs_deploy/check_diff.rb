# frozen_string_literal: true

module ObsDeploy
  class CheckDiff
    def initialize(server: 'https://api.opensuse.org', product: '15.3', project: 'OBS:Server:Unstable', target_server: 'https://api.opensuse.org')
      @server = server
      @product = product
      @project = project
      @target_server = target_server
    end

    def package_version
      doc = Nokogiri::XML(Net::HTTP.get(package_url))
      doc.xpath("//binary[starts-with(@filename, 'obs-api')]/@filename").to_s
    end

    def package_commit
      package_version.match(/obs-api-.*\..*\..*\.(.*)-.*\.rpm/).captures.first
    end

    def obs_running_commit
      doc = Nokogiri::XML(Net::HTTP.get(about_url))
      doc.xpath('//commit/text()').to_s
    end

    def github_diff
      Net::HTTP.get(URI("https://github.com/openSUSE/open-build-service/compare/#{obs_running_commit}...#{package_commit}.diff"))
    end

    def new_version_available?
      obs_running_commit != package_commit
    end

    def has_migration?
      return true if github_diff.nil? || github_diff.empty?

      GitDiffParser.parse(github_diff).files.any? { |f| f.match?(%r{db/migrate}) }
    end

    def has_data_migration?
      return true if github_diff.nil? || github_diff.empty?

      GitDiffParser.parse(github_diff).files.any? { |f| f.match?(%r{db/data}) }
    end

    def data_migrations
      return [] unless has_data_migration?

      GitDiffParser.parse(github_diff).files.select { |f| f =~ %r{db/data} }
    end

    def migrations
      return [] unless has_migration?

      GitDiffParser.parse(github_diff).files.select { |f| f =~ %r{db/migrate} }
    end

    def package_url
      URI("#{@server}/public/build/#{@project}/#{@product}/x86_64/obs-server")
    end

    def about_url
      URI("#{@target_server}/about")
    end
  end
end
