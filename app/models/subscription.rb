class Subscription < ApplicationRecord
  belongs_to :user

  validates :endpoint, presence: true
end
