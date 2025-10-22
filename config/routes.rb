Rails.application.routes.draw do
  root "services#index"

  get  "/services",                  to: "services#index",  as: :services
  get  "/services/:id",              to: "services#show",   as: :service

  # get  "/deflection-requests/:id",     to: "deflection_requests#show",   as: :deflection_request
  # post "/deflection-requests/add",     to: "deflection_requests#add",    as: :add_to_deflection_request
  # post "/deflection-requests/:id/delete", to: "deflection_requests#delete", as: :delete_deflection_request

  resources :requests do
    resources :request_services, path: :items, as: :items, only: [:create, :update, :destroy]
  end
  resources :services, only: [:index, :show]
  post 'services/:service_id/add_to_request',
     to: 'legacy_cart#add',
     as: :add_to_request
end
