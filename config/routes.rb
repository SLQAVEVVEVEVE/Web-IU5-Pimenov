Rails.application.routes.draw do
  root "beam_types#index"

  get  "/beam-types",                  to: "beam_types#index",  as: :beam_types
  get  "/beam-types/:id",              to: "beam_types#show",   as: :beam_type

  get  "/deflection-requests/:id",     to: "deflection_requests#show",   as: :deflection_request
  post "/deflection-requests/add",     to: "deflection_requests#add",    as: :add_to_deflection_request
  post "/deflection-requests/:id/delete", to: "deflection_requests#delete", as: :delete_deflection_request

end
