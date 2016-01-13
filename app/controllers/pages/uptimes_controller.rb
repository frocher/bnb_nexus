class Pages::UptimesController < ApplicationController
  before_action :authenticate_user!

  # Show uptimes for a given page and for a given period
  # returns either a single value when type is 'median' or a list of value when the type is 'list'
  def index
    @type = params[:type]
    @page = Page.find(params[:page_id])
    @start_date = Date.parse(params[:start]).beginning_of_day
    @end_date   = Date.parse(params[:end]).end_of_day

    if @type == 'median'
      result = UptimeMetrics.select("median(value) * 100 as value").by_page(params[:page_id]).where(time: @start_date..@end_date)
    else
      nbDays = (@end_date - @start_date).to_i
      interval = nbDays < 1 ? '1h' : '1d'
      result = UptimeMetrics.select("mean(value) * 100 as value").by_page(params[:page_id]).where(time: @start_date..@end_date).time('1d').fill(:none)
    end
    render json: result
  end


end
