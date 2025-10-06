Rails.application.routes.draw do
  root "services#index"               # <- это выключит welcome
  resources :services, only: [:index, :show]
  resources :orders,   only: [:show]
end

