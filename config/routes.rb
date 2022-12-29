Rails.application.routes.draw do
  root "dashboard#index"

  get "sample", to: "dashboard#sample"
  resources :stages, only: [:show]
  resources :owners, only: [:show]
  resources :projects, only: [:show]
  resources :designs, only: [:show]
  resources :works, only: [:new, :create, :show]
  get "data", to: "works#data"
  get "detail", to: "dashboard#detail"
  get "summary", to: "dashboard#summary"
end
