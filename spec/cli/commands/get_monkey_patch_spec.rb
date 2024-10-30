# frozen_string_literal: true

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', '..', 'lib')

require 'obs_deploy'
require 'dry/cli'
require 'obs_deploy/cli/commands'

RSpec.describe ObsDeploy::CLI::Commands::GetMonkeyPatch do
  let(:get_monkey_patch) { described_class.new }

  it {
    result = get_monkey_patch.call(user: 'root', host: 'localhost', port: '22')
    puts result
    expect(result).to have_text('MONKEY PATCH')
  }

  # describe 'option ignore_certificate' do
  #   let(:ignore_certificate_option) { get_diff.options.select { |o| o.name == :ignore_certificate }.first }
  #   it { expect(ignore_certificate_option).not_to be_nil }
  #   it { expect(ignore_certificate_option).to respond_to(:options) }
  #   it { expect(ignore_certificate_option.options[:aliases]).to include('k') }
  # end
end
