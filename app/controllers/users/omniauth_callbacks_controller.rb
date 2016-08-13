class Users::OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController

  def get_resource_from_auth_hash
    @resource = resource_class.from_omniauth(auth_hash)

    if @resource.new_record?
      @oauth_registration = true
    end

    @resource
  end

end
