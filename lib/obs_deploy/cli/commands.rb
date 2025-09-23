# frozen_string_literal: true

module ObsDeploy
  module CLI
    module Commands
      extend Dry::CLI::Registry

      autoload :Version, File.join(__dir__, 'commands/version.rb')
      autoload :RefreshRepositories, File.join(__dir__, 'commands/refresh_repositories.rb')
      autoload :Deploy, File.join(__dir__, 'commands/deploy.rb')
      autoload :GetPackageVersion,  File.join(__dir__, 'commands/get_package_version.rb')
      autoload :GetDeployedVersion, File.join(__dir__, 'commands/get_deployed_version.rb')
      autoload :Systemctl, File.join(__dir__, 'commands/systemctl.rb')
      autoload :GetPendingMigration, File.join(__dir__, 'commands/get_pending_migration.rb')
      autoload :GetDiff, File.join(__dir__, 'commands/get_diff.rb')

      # register the commands and its command line
      register 'available-package', GetPackageVersion, aliases: ['ap']
      register 'deployed-version', GetDeployedVersion, aliases: ['dv']
      register 'version', Version, aliases: ['v', '-v', '--version']
      register 'refresh-repositories', RefreshRepositories, aliases: ['rr']
      register 'systemctl', Systemctl, aliases: ['sys']
      register 'pending-migrations', GetPendingMigration, aliases: ['pm']
      register 'check-diff', GetDiff, aliases: ['cd']
    end
  end
end
