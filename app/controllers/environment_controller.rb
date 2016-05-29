class EnvironmentController < ApplicationController
  def index
    resu = Hash.new
    resu["GOOGLE_ANALYTICS_KEY"] = Figaro.env.google_analytics_key
    render json: resu
  end
end
