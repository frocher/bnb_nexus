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
      result = UptimeMetrics.select("median(value) as value").by_page(params[:page_id]).where(time: @start_date..@end_date)
    else
      # TODO : we must not have more than X points to display
      # we must so calculate the correct interval between points
      result = UptimeMetrics.by_page(params[:page_id]).where(time: @start_date..@end_date).time('1d').mean(:value)
    end
    render json: result
  end


end
