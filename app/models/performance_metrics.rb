class PerformanceMetrics < Influxer::Metrics
  set_series :performance
  tags :page_id
  attributes :response_start, :first_paint, :speed_index, :dom_ready, :page_load_time

  scope :by_page, -> (id) { where(page_id: id) if id.present? }
end
