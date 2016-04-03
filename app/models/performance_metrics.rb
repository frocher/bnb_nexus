class PerformanceMetrics < Influxer::Metrics
  set_series :performance
  tags :page_id, :target, :probe
  attributes :response_start, :first_paint, :speed_index, :dom_ready, :page_load_time

  scope :by_page, -> (id) { where(page_id: id) if id.present? }
  scope :by_target, -> (target) { where(target: target) if target.present? }
  scope :desktop, -> { where(target: "desktop") }
  scope :mobile,  -> { where(target: "mobile") }
end
