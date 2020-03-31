# frozen_string_literal: true

RSpec.describe ObsDeploy::CheckDiff do
  let(:check_diff) { described_class.new }
  let(:http_response) { fixture_file }

  it { expect(check_diff).not_to be_nil }

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

  describe 'has_migration?' do
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
        it { expect(check_diff).to have_migration }
      end
      context 'no pending migration' do
        let(:fixture_file) { File.new('spec/fixtures/github_diff_without_migration.txt') }
        let(:running_commit) { 'bc7f6c0' }
        let(:package_commit) { '554e943' }
        it { expect(check_diff).not_to have_migration }
      end
    end

    context 'no data is present' do
      context 'if no git diff is present it should abort' do
        before do
          allow(check_diff).to receive(:github_diff).and_return(nil)
        end
        it { expect(check_diff).to have_migration }
      end
    end
  end
end
