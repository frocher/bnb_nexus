# == Schema Information
#
# Table name: users
#
#  id                     :bigint(8)        not null, primary key
#  provider               :string(255)      not null
#  uid                    :string(255)      default(""), not null
#  admin                  :boolean          default(FALSE)
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  name                   :string(255)
#  bio                    :string(255)
#  email                  :string(255)
#  tokens                 :text(65535)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  image                  :string(255)
#  subscription           :string(255)
#

require "stripe"

class User < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User

  before_create :record_first_admin

  alias_attribute :nickname, :name

  has_many :page_members, dependent: :destroy
  has_many :pages, through: :page_members
  has_many :identities, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

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

  def owned_pages
    Page.joins(:page_members).where(user: self, role: 3).order(:created_at)
  end

  def stripe_subscription
    plan_id = -1

    unless subscription.nil?
      Stripe.api_key = Figaro.env.stripe_secret_key
      subscription_object = Stripe::Subscription.retrieve(subscription)
      if subscription_object.status != "canceled" && subscription_object.status != "unpaid"
        plan_id = subscription_object.plan.id
      end
    end

    plan = find_plan(plan_id)
    resu = Hash.new
    resu["plan"] = plan_id
    resu["pages"] = plan["pages"]
    resu["members"] = plan["members"]
    resu["uptime"] = plan["uptime"]
    resu["current"] = owned_pages.count

    resu
  end

  def update_pages_lock()
    if Figaro.env.stripe_api_key?
      max_pages = @user.stripe_subscription["pages"]
      index = 0
      owned_pages.each do |page|
        page.locked = index >= max_pages
        page.save
        index += 1
      end
    end
  end

  #
  # Class methods
  #
  class << self
    def from_omniauth(auth)
      user = nil
      identity = Identity.where(provider: auth.provider, uid: auth.uid).first
      if identity
        user = identity.user
      else
        user = User.find_by(email: auth.info.email) || User.create!(uid: auth.uid, provider: auth.provider, email: auth.info.email, password: Devise.friendly_token[0,20], name: (auth.info.name || auth.info.full_name).to_s)
        identity = Identity.create(provider: auth.provider, uid: auth.uid, user: user)
      end
      user
    end

  end


  private

  def find_plan(id)
    plans = Rails.application.config.stripe_plans.select{ |o| o["id"] == id }
    plans.first
  end

  # First user is always super admin
  def record_first_admin
    if User.count == 0
      self.admin = true
    end
  end

end
