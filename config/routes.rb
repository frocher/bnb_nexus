Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  resources :pages do
    scope module: :pages do
      resources :checks, only: [:index]
      resources :uptimes, only: [:index]
      resources :members, only: [:index]
    end
  end
  get "/pages/:id/screenshot" => "pages#screenshot"

  if Rails.env.development?
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
