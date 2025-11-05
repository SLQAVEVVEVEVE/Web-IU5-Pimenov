Rails.application.routes.draw do
  root "services#index"               # <- это выключит welcome
  resources :services, only: [:index, :show]
  resources :orders, only: [:show] do
    member do
      post :complete
    end
  end
  
  resource  :cart, only: [:show], controller: "carts" do
    resources :items, only: [:create], controller: "cart_items"
    post :delete, to: "carts#delete"
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
