Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  # resources :pages, only: [:show]

  resources :pages do
    get '/search', to: 'pages#search', as: 'search'
    get '/pages/:id', to: 'pages#show'
  end

  resources :events, only: [:index, :show] do
    resources :bookings, only: [:index, :create, :update]
  end
end
