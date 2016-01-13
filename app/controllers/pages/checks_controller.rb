class Pages::ChecksController < ApplicationController
  before_action :authenticate_user!

  # Show performance checks for a given page and for a given period
  # returns either a single value when type is 'median' or a list of value when the type is 'list'
  def index
    @type = params[:type]
    @page = Page.find(params[:page_id])
    @start_date = Date.parse(params[:start]).beginning_of_day
    @end_date   = Date.parse(params[:end]).end_of_day

    if @type == 'median'
      selectValue = "median(dom_ready) as dom_ready," \
                    "median(first_paint) as first_paint," \
                    "median(page_load_time) as page_load," \
                    "median(response_start) as response_start," \
                    "median(speed_index) as speed_index"
      result = PerformanceMetrics.select(selectValue).by_page(params[:page_id]).where(time: @start_date..@end_date)
    else
      selectValue = "mean(dom_ready) as dom_ready," \
                    "mean(first_paint) as first_paint," \
                    "mean(page_load_time) as page_load," \
                    "mean(response_start) as response_start," \
                    "mean(speed_index) as speed_index"

      nbDays = (@end_date - @start_date).to_i
      interval = nbDays < 1 ? '1h' : '1d'

      result = PerformanceMetrics.select(selectValue).by_page(params[:page_id]).where(time: @start_date..@end_date).time(interval).fill(:none)
    end
    render json: result
  end
end
