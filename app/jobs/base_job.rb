class BaseJob

  def choose_probe
    probes = Rails.application.config.probes
    probe = probes.sample
  end

end
