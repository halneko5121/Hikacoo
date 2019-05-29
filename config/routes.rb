Rails.application.routes.draw do
  root to: 'toppages#index'
  
  post "search", to: "toppages#search"
  post "comparison", to: "toppages#comparison"
end
