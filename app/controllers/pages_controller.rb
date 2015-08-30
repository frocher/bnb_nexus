class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:screenshot]

  def index
    if current_user.is_admin? && params[:admin] == 'true'
      @pages = paginate(Page.all)
    else
      @pages = paginate(@resource.pages)
    end
    render json: @pages
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

  def screenshot
    @page = Page.find(params[:id])
    path = File.join(Rails.root, 'public', 'screenshot.png')
    path = @page.screenshot.path if @page.screenshot.exists?
    data = File.read(path)
    send_data data, disposition: 'inline'
  end

  def update
    # TODO
  end

private

  def page_params
    params.require(:page).permit(:name, :url)
  end

end
