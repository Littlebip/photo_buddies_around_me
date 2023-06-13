Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  get '/search', to: 'pages#search', as: 'search'
end
