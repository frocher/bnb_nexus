class User < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User

  before_create :record_first_admin


  has_many :site_members, dependent: :destroy
  has_many :sites, through: :site_members

  # Scopes
  scope :admins, -> { where(admin: true) }

  #
  # Validations
  #
  validates :name, presence: true, uniqueness: true
  validates :bio, length: { maximum: 500 }, allow_blank: true         

  def is_admin?
    admin
  end


  def avatar_url
    ApplicationController.helpers.avatar_icon(email)
  end
  
  private

  # First user is always super admin
  def record_first_admin
    if User.count == 0
      self.admin = true
    end
  end

end
