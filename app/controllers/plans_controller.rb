class PlansController < ApplicationController
  def index
    resu = Array.new
    if Figaro.env.stripe_api_key?
      resu = Rails.application.config.stripe_plans
    end
    render json: resu
  end
end
