Rails.application.routes.draw do
  root to: 'toppages#index'

  post "/", to: "toppages#index"

  get "search", to: "toppages#search"
  get "comparison", to: "toppages#comparison"
end
