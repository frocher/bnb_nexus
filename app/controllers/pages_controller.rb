class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:screenshot]
  before_action :set_page, only: [:show, :update, :destroy]

  def index
    if current_user.is_admin? && params[:admin] == 'true'
      @pages = paginate(Page.all)
    else
      @pages = paginate(@resource.pages)
    end
    render json: @pages
  end

  def show
    return not_found! unless can?(current_user, :read_page, @page)
    editable  = can?(current_user, :update_page, @page)
    deletable = can?(current_user, :delete_page, @page)
    render json: @page.as_json().merge({editable: editable, deletable: deletable})
  end

  def create
    Page.transaction do
      begin
        @page = Page.new

        @page.name = params[:name]
        @page.url = params[:url]
        @page.save!

        member = PageMember.new
        member.page = @page
        member.user = current_user
        member.role = :admin
        member.save!

        render json: @page
      rescue ActiveRecord::RecordInvalid
        render json: {errors: @page.errors}, status: 422
      end
    end
  end

  def update
    return not_found! unless can?(current_user, :update_page, @page)

    @page.name = params[:name]
    @page.url = params[:url]
    @page.save!

    render json: @page

    rescue ActiveRecord::RecordInvalid
      render json: {errors: @page.errors}, status: 422
  end

  def destroy
    return not_found! unless can?(current_user, :update_page, @page)
    @page.destroy
    render json: @page
  end

  def screenshot
    @page = Page.find(params[:id])
    if params.has_key?(:style)
      style = params[:style]
    else
      style = "original"
    end
    path = File.join(Rails.root, 'public', 'screenshot.png')
    path = @page.screenshot.path(style) if @page.screenshot.exists?
    data = File.read(path)
    send_data data, type: 'image/png', disposition: 'inline'
  end


private

  def set_page
    @page = Page.find(params[:id])
  end

  def page_params
    params.require(:page).permit(:name, :url)
  end

end
