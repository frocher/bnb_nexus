class AssetsMetrics < Influxer::Metrics
  set_series :assets
  tags :page_id, :probe, :time_key
  attributes :html_requests, :js_requests, :css_requests, :image_requests, :font_requests, :other_requests,
             :html_bytes, :js_bytes, :css_bytes, :image_bytes, :font_bytes, :other_bytes

  scope :by_page, -> (id) { where(page_id: id) if id.present? }
end
