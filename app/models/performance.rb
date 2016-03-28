# == Schema Information
#
# Table name: performances
#
#  id         :integer          not null, primary key
#  page_id    :integer          not null
#  har        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Performance < ActiveRecord::Base
  belongs_to :page

  # response start : default.statistics.responseStart.median
  # firstPaint : default.statistics.firstPaint.median
  # speed index : default.statistics.speedIndex.median
  # dom ready : default.statistics.domInteractive.median
  # page load time : default.statistics.pageLoadTime.median

  #
  # Validations
  #
  validates :har, presence: true
end
