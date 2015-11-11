Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  resources :pages do
    scope module: :pages do
      resources :checks, only: [:show]
      resources :uptimes, only: [:show]
    end
  end
  get "/pages/:id/screenshot" => "pages#screenshot"

end
