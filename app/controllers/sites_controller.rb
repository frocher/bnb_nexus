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
end
