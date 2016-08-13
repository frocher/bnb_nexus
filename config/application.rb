require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BnbNexus
  class Application < Rails::Application
    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :sidekiq

    # Array of probes for pages checks and measures
    config.probes = JSON.parse(Figaro.env.probes)

    config.middleware.insert_before ActionDispatch::ParamsParser, "SessionStack"
  end
end
