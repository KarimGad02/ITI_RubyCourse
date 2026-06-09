Rails.application.routes.draw do
  devise_for :users
  
  resources :articles do
    member do
      post 'report' # Creates a route: POST /articles/:id/report
    end
  end

  root "articles#index"
end