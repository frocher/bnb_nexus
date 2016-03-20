class Pages::MembersController < ApplicationController
  before_action :authenticate_user!
  def index
    @page = Page.find(params[:page_id])
    return not_found! unless can?(current_user, :read_page_member, @page)
    render json: @page.page_members
  end
end
