# frozen_string_literal: true

require 'open-uri'
require 'net/http'
require 'cheetah'
require 'logger'
require 'nokogiri'
require 'git_diff_parser'
require 'obs_deploy/version'
require 'obs_deploy/ssh_info'
require 'obs_deploy/api_info'
require 'obs_deploy/check_diff'
require 'obs_deploy/ssh'
require 'obs_deploy/zypper'
require 'obs_deploy/systemctl'
require 'obs_deploy/apache_sysconfig'
require 'tempfile'

module ObsDeploy
  class Error < StandardError; end

  # API config
  DEFAULT_URL = 'https://api.opensuse.org'
  DEFAULT_PRODUCT = '16.0'
  DEFAULT_PACKAGE = 'obs-api'
  DEFAULT_SOURCE_PACKAGE = 'obs-server'
  DEFAULT_ARCHITECTURE = 'x86_64'
  DEFAULT_PROJECT = 'OBS:Server:Unstable'

  # SSH config
  DEFAULT_USER = 'root'
  DEFAULT_HOST = 'obs'
  DEFAULT_PORT = 22
end
