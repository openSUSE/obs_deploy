# frozen_string_literal: true

module ObsDeploy
  class ApacheSysconfig
    attr_reader :path

    def initialize
      @path = '/etc/sysconfig/apache2'
    end

    def enable_maintenance_mode
      return if maintenance_mode?

      content = File.read(path).gsub(/^#{server_flags}="STATUS"$/,
                                     apache_status_line(maintenance))
      write_apache_sysconfig(content)
    end

    def disable_maintenance_mode
      return unless maintenance_mode?

      content = File.read(path).gsub(/^#{server_flags}="STATUS MAINTENANCE"/,
                                     apache_status_line(no_maintenance))
      write_apache_sysconfig(content)
    end

    def maintenance_mode?
      find_server_flags.all? { |r| r.include?('MAINTENANCE') }
    end

    private

    def no_maintenance
      'STATUS'
    end

    def maintenance
      'STATUS MAINTENANCE'
    end

    def server_flags
      'APACHE_SERVER_FLAGS'
    end

    def apache_status_line(status)
      "#{server_flags}=\"#{status}\""
    end

    def find_server_flags
      File.readlines(path).grep(/^#{server_flags}=/)
    end

    def write_apache_sysconfig(content)
      f = Tempfile.new
      f.write(content)
      begin
        File.rename(f.path, path)
      rescue SystemCallError => e
        puts e.inspect
      ensure
        f.unlink
        f.close
      end
    end
  end
end
