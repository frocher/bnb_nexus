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

require 'test_helper'

class UptimeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
