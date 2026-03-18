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
    resources :agency_staffing_requests, only: %i[create destroy]
  end

  # Hotel side: accept/reject individual agency candidates
  resources :agency_staffing_candidates, only: [] do
    member do
      patch :accept
      patch :reject
    end
  end

  # Agency side: incoming staffing requests from the hotel
  resources :agency_incoming_requests, only: %i[index show] do
    member do
      patch :decline
      patch :submit_candidates
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
      post  :reset_password
    end
  end

  resources :invitations, only: :index do
    member do
      patch :accept
      patch :decline
      patch :waitlist
    end
  end

  # Admin: agency management
  resources :agencies, only: %i[index new create]

  # Public: agency registration via token
  get  "/agency_signup/:token", to: "agency_registrations#new",    as: :agency_signup
  post "/agency_signup/:token", to: "agency_registrations#create"

  # Agency admin dashboard + connection confirmation
  resource :agency_dashboard, controller: "agency_dashboard", only: :show do
    patch :confirm, on: :member
  end

  # Agency staff roster
  resources :agency_staff_members do
    member do
      patch :blacklist
      patch :unblacklist
    end
  end

  root to: "pages#home"
end
