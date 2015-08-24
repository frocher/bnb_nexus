# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  provider               :string           not null
#  uid                    :string           default(""), not null
#  admin                  :boolean          default(FALSE)
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  name                   :string
#  bio                    :string
#  email                  :string
#  tokens                 :text
#  created_at             :datetime
#  updated_at             :datetime
#

class User < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User

  before_create :record_first_admin


  has_many :page_members, dependent: :destroy
  has_many :pages, through: :page_members

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
