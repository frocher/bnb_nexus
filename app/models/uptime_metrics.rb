class UptimeMetrics < Influxer::Metrics
  set_series :uptime
  tags :page_id
  attributes :value, :error_code, :error_message, :error_content

  scope :by_page, -> (id) { where(page_id: id) if id.present? }
end
