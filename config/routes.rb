Rails.application.routes.draw do
  root "dashboard#index"

  resources :stages, only: [:show]
  resources :owners, only: [:show]
  resources :projects, only: [:show]
  resources :designs, only: [:show]
  resources :works, only: [:new, :create, :show]
  get "data/summary", to: "works#get_summary"
  get "data/work", to: "works#get_work"
  get "data/chart", to: "works#get_chart"
  get "data/edit", to: "works#edit"
  get "data/delete", to: "works#delete"
  get "export", to: "works#export"
  get "detail", to: "dashboard#detail"
  get "summary", to: "dashboard#summary"
  get "chart", to: "dashboard#chart"
  #get "statistic", to: "dashboard#statistic"

  get  "login",  to: 'owner_sessions#new', :as => :login
  get  "login_status",  to: 'owner_sessions#status'
  post "login",  to: "owner_sessions#create"
  get "logout", to: 'owner_sessions#destroy', :as => :logout
end
