require "stripe"

class PlansController < ApplicationController
  def index
    resu = Array.new
    unless Figaro.env.stripe_api_key?
      Stripe.api_key = Figaro.env.stripe_secret_key
      plans = Stripe::Plan.list()
      plans.data.each do |plan|
        plan_resu = Hash.new
        plan_resu["id"] = plan.id
        plan_resu["amount"] = plan.amount / 100.0
        plan_resu["interval"] = plan.interval
        product = Stripe::Product.retrieve(plan.product)
        plan_resu["name"] = product.name
        plan_resu["pages"] = product.metadata.pages
        plan_resu["members"] = product.metadata.members
        plan_resu["uptime"] = product.metadata.uptime
        resu.push(plan_resu)
      end
      resu = resu.sort_by { |hsh| hsh["amount"] }
    end
    render json: resu
  end
end
