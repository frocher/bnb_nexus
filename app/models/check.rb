# == Schema Information
#
# Table name: checks
#
#  id             :integer          not null, primary key
#  page_id        :integer          not null
#  response_start :integer          not null
#  first_paint    :integer          not null
#  speed_index    :integer          not null
#  dom_ready      :integer          not null
#  page_load_time :integer          not null
#  har            :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Check < ActiveRecord::Base
  belongs_to :page

  # response start : default.statistics.responseStart.median
  # firstPaint : default.statistics.firstPaint.median
  # speed index : default.statistics.speedIndex.median
  # dom ready : default.statistics.domInteractive.median
  # page load time : default.statistics.pageLoadTime.median


  #
  # Validations
  #
  validates :responseStart, presence: true
  validates :firstPaint, presence: true
  validates :speedIndex, presence: true
  validates :domReady, presence: true
  validates :pageLoadTime, presence: true
  validates :har, presence: true
end
