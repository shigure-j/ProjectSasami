Rails.application.routes.draw do
  root "dashboard#index"

  get "sample", to: "dashboard#sample"
  resources :stages, only: [:show]
  resources :owners, only: [:show]
  resources :projects, only: [:show]
  resources :designs, only: [:show]
  resources :works, only: [:new, :create, :show]
  get "data/summary", to: "works#get_summary"
  get "data/work", to: "works#get_work"
  get "detail", to: "dashboard#detail"
  get "summary", to: "dashboard#summary"

  get  "login",  to: 'owner_sessions#new', :as => :login
  post "login",  to: "owner_sessions#create"
  post "logout", to: 'owner_sessions#destroy', :as => :logout
end
