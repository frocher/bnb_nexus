class SitesController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.is_admin? && params[:admin] == 'true'
      @sites = paginate(Site.all)
    else
      @sites = paginate(@resource.sites)
    end
    render json: @sites
  end

  def create
    Site.transaction do
      begin
        @site = Site.new
        @page = Page.new

        @site.name = params[:name]
        @site.save!

        @page.url = params[:url]
        @page.site = @site
        @page.save!

        member = SiteMember.new
        member.site = @site
        member.user = current_user
        member.role = :admin
        member.save!

        render json: @site
      rescue ActiveRecord::RecordInvalid
        if @site.errors.count != 0
          render json: { errors: @site.errors}, status: 422
        else
          render json: { errors: @page.errors}, status: 422
        end
      end
    end
  end

  def update
    # TODO
  end

private

  def site_params
    params.require(:site).permit(:name, :url)
  end

end
