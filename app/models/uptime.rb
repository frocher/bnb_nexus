# == Schema Information
#
# Table name: uptimes
#
#  id         :integer          not null, primary key
#  page_id    :integer          not null
#  error_code :integer          not null
#  error_text :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Uptime < ActiveRecord::Base
  belongs_to :page

  #
  # Validations
  #
  validates :errorCode, presence: true
  validates :errorText, presence: true
end
