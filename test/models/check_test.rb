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

require 'test_helper'

class CheckTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
