class PageMember < ActiveRecord::Base
  enum role: {guest: 0, master: 1, admin: 2}

  belongs_to :user
  belongs_to :page

  validates :user, presence: true
  validates :page, presence: true
  validates :user_id, uniqueness: { scope: [:page_id], message: "already exists in page" }

  scope :guests, ->     { where("role = :role", role: 0) }
  scope :masters, ->    { where("role = :role", role: 1) }
  scope :admins, ->     { where("role = :role", role: 2) }

  def username
    user.name
  end
end
