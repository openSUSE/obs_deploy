# frozen_string_literal: true

require 'open-uri'
require 'net/http'
require 'cheetah'
require 'logger'

require 'nokogiri'
require 'obs_deploy/version'
require 'obs_deploy/check_diff'
require 'obs_deploy/ssh'
require 'obs_deploy/zypper'
require 'obs_deploy/systemctl'

module ObsDeploy
  class Error < StandardError; end
end
