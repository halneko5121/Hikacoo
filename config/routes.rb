Rails.application.routes.draw do
  root to: 'toppages#index'

  post "/", to: "toppages#index"

  post "search", to: "toppages#search"
  get "search", to: "toppages#index"

  post "comparison", to: "toppages#comparison"
  get "comparison", to: "toppages#index"
end
