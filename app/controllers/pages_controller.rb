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
    # TODO
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
        render json: { errors: @page.errors}, status: 422
      end
    end
  end

  def update
    # TODO
  end

  def destroy
    # TODO
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
