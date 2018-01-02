Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  resources :environment, only: [:index]
  resources :users, only: [:show, :update]

  resources :pages do
    scope module: :pages do
      resources :stats, only: [:index]
      resources :members, except: :show
    end
  end
  get "/pages/:id/screenshot" => "pages#screenshot"
  get "/pages/:id/lighthouse/:key" => "pages#lighthouse"
end
