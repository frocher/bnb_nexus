class Pages::UptimesController < ApplicationController

  # Show uptimes for a given page and for a given period
  # returns either a single value when type is 'median' or a list of value when the type is 'list'
  def show
    @type = params[:type]
    @page = Page.find(params[:page_id])
    @start_date = Date.parse(params[:start]).beginning_of_day
    @end_date   = Date.parse(params[:end]).end_of_day

    if type == 'median'
    else
      # TODO : we must not have more than X points to display
      # we must so calculate the correct interval between points
    end

  end


end
