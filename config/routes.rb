Rails.application.routes.draw do
  # get "/products", to: "products#index"

  # get "/products/new", to: "products#new"
  # post "/products", to: "products#create"

  # get "/products/:id", to: "products#show"

  # get "/products/:id/edit", to: "products#edit"
  # patch "/products/:id", to: "products#update"
  # put "/products/:id", to: "products#update"

  # delete "/products/:id", to: "products#destroy"

  # This line sets the root path of the application to the index action of the products controller
  root "products#index"
  #this line replaces all the above CRUD routes for products
  resources :products
end
