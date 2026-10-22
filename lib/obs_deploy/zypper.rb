# frozen_string_literal: true

module ObsDeploy
  class Zypper
    attr_accessor :dry_run

    def initialize(dry_run: true, package_name: 'obs-api')
      @dry_run = dry_run
      @package_name = package_name
    end

    def update
      run %w[zypper] + update_string + package_name
    end

    def refresh
      run %w[zypper --non-interactive --gpg-auto-import-keys refresh]
    end

    # TODO
    # check if we want to lock from specific repositories
    def add_lock
      run %w[zypper addlock] + package_name
    end

    def remove_lock
      run %w[zypper removelock] + package_name
    end

    def locked?
      # check the return value
      run %w[zypper locks] + package_name
    end

    def info
      run %w[zypper --no-color info] + package_name
    end

    private

    def run(params)
      params
    end

    def update_string
      if @dry_run
        update_params + dry_run_params
      else
        update_params
      end
    end

    def package_name
      [@package_name]
    end

    def update_params
      %w[--non-interactive update --best-effort --details]
    end

    def dry_run_params
      %w[--dry-run --download-only]
    end
  end
end
