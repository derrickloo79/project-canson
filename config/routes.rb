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
    resources :event_roles, only: [] do
      resources :event_invitations, only: [ :create, :destroy ]
    end
  end

  get "/approvals", to: "approvals#index", as: :approvals

  resources :roles, except: :show do
    member do
      patch :toggle
    end
  end

  resources :staff_members do
    member do
      patch :blacklist
      patch :unblacklist
      post  :create_login
    end
  end

  resources :invitations, only: :index do
    member do
      patch :accept
      patch :decline
    end
  end

  root to: "pages#home"
end
