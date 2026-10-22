module ObsDeploy
  class SshInfo
    VERSION_REGEX = /.*\..*\..*\.(.*)-.*/

    def self.available?(user: ObsDeploy::DEFAULT_USER, host: ObsDeploy::DEFAULT_HOST, port: ObsDeploy::DEFAULT_PORT)
      true
    end

    def initialize(user: ObsDeploy::DEFAULT_USER, host: ObsDeploy::DEFAULT_HOST, port: ObsDeploy::DEFAULT_PORT)
      @ssh_driver = ObsDeploy::SSH.new(user:, server: host, port:)
      @zypper = ObsDeploy::Zypper.new
      @zypper_info = zypper_info
    end

    def deployed_version
      version = @zypper_info['Status']&.match(/out-of-date \(version (.*) installed\)/)&.captures&.first || @zypper_info['Version']
      version.match(VERSION_REGEX).captures.first
    end

    def available_version
      version = @zypper_info['Version']
      version.match(VERSION_REGEX).captures.first
    end

    private

    def zypper_info
      output = @ssh_driver.run(@zypper.info)
      # Table items containing newline start with 4 spaces, so we turn all of them into single line strings
      table = output.gsub("\n    ", ' ')
      lines = table.lines(chomp: true).reject { |i| !i.include?(':') }
      lines.to_h do |i|
        split = i.split(':')
        [split.shift.strip, split.join(':').strip]
      end
    end
  end
end
