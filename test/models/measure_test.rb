# == Schema Information
#
# Table name: measures
#
#  id         :integer          not null, primary key
#  category   :string
#  value      :integer
#  page_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class MeasureTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
