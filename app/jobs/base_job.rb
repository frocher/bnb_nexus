class BaseJob < ActiveJob::Base

  def choose_probe
    probes = Rails.application.config.probes
    probe = probes.sample
  end

end
