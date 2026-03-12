Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  resources :events do
    member do
      get   :step1
      get   :step2
      get   :step3
      patch :update_step1
      patch :update_step2
      patch :update_step3
      patch :save_draft
      patch :approve
      patch :reject
    end
  end

  get "/approvals", to: "approvals#index", as: :approvals

  root to: "pages#home"
end
