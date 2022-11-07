# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ObsDeploy::CheckDiff do
  let(:check_diff) { described_class.new }
  let(:http_response) { fixture_file }

  it { expect(check_diff).not_to be_nil }

  describe '#package_url' do
    subject { check_diff.package_url.to_s }
    context 'default parameter' do
      let(:url) { "https://api.opensuse.org/public/build/OBS:Server:Unstable/#{ObsDeploy::DEFAULT_PRODUCT}/x86_64/obs-server" }
      it { expect(subject).to eq(url) }
    end

    context 'project = OBS:Server:2.10:Staging' do
      let(:check_diff) { described_class.new(product: 'openSUSE_15.3', project: 'OBS:Server:2.10:Staging') }
      let(:url) { 'https://api.opensuse.org/public/build/OBS:Server:2.10:Staging/openSUSE_15.3/x86_64/obs-server' }
      it { expect(subject).to eq(url) }
    end
  end
  describe '#package_version' do
    let(:fixture_file) { File.new('spec/fixtures/package.txt') }
    let(:package_name) { 'obs-api-2.11~alpha.20200330T141742.e179ddc8f9-9958.1.noarch.rpm' }
    subject { check_diff.package_version }

    before do
      stub_request(:get, check_diff.package_url).to_return(http_response)
    end

    it { expect(subject).not_to be_nil }
    it { expect(subject).to eq(package_name) }
  end

  describe '#package_commit' do
    let(:fixture_file) { File.new('spec/fixtures/package.txt') }

    subject { check_diff.package_commit }

    before do
      stub_request(:get, check_diff.package_url).to_return(http_response)
    end

    it { expect(subject).not_to be_nil }
    it { expect(subject).to eq('e179ddc8f9') }
  end

  describe 'data_migration?' do
    let(:diff_url) { "https://github.com/openSUSE/open-build-service/compare/#{running_commit}...#{package_commit}.diff" }

    before do
      allow(check_diff).to receive(:obs_running_commit).and_return(running_commit)
      allow(check_diff).to receive(:package_commit).and_return(package_commit)
      stub_request(:get, diff_url).to_return(fixture_file)
    end

    context 'pending migration' do
      let(:fixture_file) { File.new('spec/fixtures/github_diff_with_data_migration.txt') }
      let(:running_commit) { '2392177' }
      let(:package_commit) { '8c6783b' }
      it { expect(check_diff.migration?).to be true }
      it { expect(check_diff.data_migrations).not_to be_empty }
    end
  end

  describe 'migration?' do
    context 'data is present' do
      let(:diff_url) { "https://github.com/openSUSE/open-build-service/compare/#{running_commit}...#{package_commit}.diff" }
      before do
        allow(check_diff).to receive(:obs_running_commit).and_return(running_commit)
        allow(check_diff).to receive(:package_commit).and_return(package_commit)
        stub_request(:get, diff_url).to_return(fixture_file)
      end

      context 'pending migration' do
        let(:fixture_file) { File.new('spec/fixtures/github_diff_with_migration.txt') }
        let(:running_commit) { '52a3a8b' }
        let(:package_commit) { '2c565b0' }
        it { expect(check_diff.migration?).to be true }
      end
      context 'no pending migration' do
        let(:fixture_file) { File.new('spec/fixtures/github_diff_without_migration.txt') }
        let(:running_commit) { 'bc7f6c0' }
        let(:package_commit) { '554e943' }
        it { expect(check_diff.migration?).to be false }
      end

      context 'migration file cited in the rubocop configuration' do
        let(:fixture_file) { File.new('spec/fixtures/github_diff_false_positive_migration.txt') }
        let(:running_commit) { '4987339b496' }
        let(:package_commit) { '564a33f4aa9' }

        it { expect(check_diff.migration?).to be false }
      end
    end

    context 'no data is present' do
      context 'if no git diff is present it should abort' do
        before do
          allow(check_diff).to receive(:github_diff).and_return(nil)
        end
        it { expect(check_diff.migration?).to be true }
      end
    end
  end

  describe '#data_migrations' do
    subject { check_diff.data_migrations }

    context 'no pending migration' do
      let(:diff_url) { "https://github.com/openSUSE/open-build-service/compare/#{running_commit}...#{package_commit}.diff" }
      let(:fixture_file) { File.new('spec/fixtures/github_diff_with_data_migration.txt') }
      let(:running_commit) { 'bc7f6c0' }
      let(:package_commit) { '554e943' }
      before do
        allow(check_diff).to receive(:obs_running_commit).and_return(running_commit)
        allow(check_diff).to receive(:package_commit).and_return(package_commit)
        stub_request(:get, diff_url).to_return(fixture_file)
      end

      it { expect(subject).not_to be_empty }
      it { expect(subject).to include('src/api/db/data/20200424080753_generate_web_notifications.rb') }
    end
  end

  describe '#migrations' do
    subject { check_diff.migrations }

    context 'no pending migration' do
      let(:diff_url) { "https://github.com/openSUSE/open-build-service/compare/#{running_commit}...#{package_commit}.diff" }
      let(:fixture_file) { File.new('spec/fixtures/github_diff_without_migration.txt') }
      let(:running_commit) { 'bc7f6c0' }
      let(:package_commit) { '554e943' }
      before do
        allow(check_diff).to receive(:obs_running_commit).and_return(running_commit)
        allow(check_diff).to receive(:package_commit).and_return(package_commit)
        stub_request(:get, diff_url).to_return(fixture_file)
      end

      it { expect(check_diff.github_diff).not_to be_empty }
      it { expect(check_diff.migration?).to be false }
    end

    context 'data is present' do
      let(:diff_url) { "https://github.com/openSUSE/open-build-service/compare/#{running_commit}...#{package_commit}.diff" }
      before do
        allow(check_diff).to receive(:obs_running_commit).and_return(running_commit)
        allow(check_diff).to receive(:package_commit).and_return(package_commit)
        stub_request(:get, diff_url).to_return(fixture_file)
      end

      context 'pending migration' do
        let(:fixture_file) { File.new('spec/fixtures/github_diff_with_migration.txt') }
        let(:migration_file) { 'db/migrate/20180110074142_change_handler_to_longtext_in_delayed_jobs.rb' }
        let(:running_commit) { '52a3a8b' }
        let(:package_commit) { '2c565b0' }
        it { expect(subject.first).to include(migration_file) }
      end
    end
  end
end
