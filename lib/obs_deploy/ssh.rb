# frozen_string_literal: true

module ObsDeploy
  class SSH
    attr_reader :user, :server, :port, :identity_file

    def initialize(opts = {})
      @user = opts[:user] || 'root'
      @server = opts[:server] || 'localhost'
      @port = opts[:port] || 22
      @identity_file = opts[:identity_file]
      @debug = opts[:debug] || false
    end

    def build_command
      ['ssh'] + basic_connection_string + identity + ssh_port
    end

    def run(cmd)
      Cheetah.run(build_command + cmd, logger:)
    end

    private

    # -t Force pseudo-tty allocation.
    # This can be used to execute arbitrary screen-based programs on a
    # remote machine, which can be very useful, e.g. when implementing menu services.
    # Multiple -t
    # options force tty allocation, even if ssh has no local tty.
    def ssh_tt
      ['-tt']
    end

    def identity
      @identity_file ? ['-i', @identity_file] : []
    end

    def basic_connection_string
      ssh_tt + [[@user, '@', @server].join]
    end

    def ssh_port
      @port && @port != 22 ? ['-p', @port.to_s] : []
    end

    def logger
      Logger.new($stdout, level: logger_level, formatter: logger_formatter)
    end

    def logger_level
      @debug ? Logger::DEBUG : Logger::INFO
    end

    def logger_formatter
      proc do |severity, _datetime, _progname, msg|
        "#{severity} - #{msg}\n"
      end
    end
  end
end
