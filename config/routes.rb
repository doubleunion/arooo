Rails.application.routes.draw do
  root to: "sessions#login"

  namespace :members do
    root to: "users#index"

    resources :users, only: [:index, :show, :edit, :update] do
      get "setup" => "users#setup"
      patch "setup" => "users#finalize"

      resource :dues, only: [:show, :update]
      delete "cancel" => "dues#cancel"
      post "scholarship_request" => "dues#scholarship_request"

      resource :key_members, only: [:edit, :update]
      resource :voting_members, only: [:edit, :update]
    end
    resources :votes, only: [:create, :destroy]

    resources :applications, only: [:index, :show] do
      resources :comments, only: :create
      post "sponsor" => "applications#sponsor"
    end
    resources :comments, only: :index

    resources :caches, only: :index do
      post :expire, on: :collection
    end
  end

  namespace :admin do
    resource :exceptions, only: :show
    resources :memberships, only: [:index, :update]
    patch "memberships/:id/change_membership_state" => "memberships#change_membership_state", :as => "change_membership_state"
    patch "memberships/:id/make_admin" => "memberships#make_admin", :as => "make_admin"
    patch "memberships/:id/unmake_admin" => "memberships#unmake_admin", :as => "unmake_admin"
    patch "door_codes/:id/disable_door_code" => "door_code#disable_door_code", :as => "disable_door_code"
    patch "door_codes/:id/enable_door_code" => "door_code#enable_door_code", :as => "enable_door_code"
    patch "users/:id/generate_door_code" => "door_code#generate_new_for_user", :as => "generate_door_code"
  end

  get "admin/new_members" => "admin#new_members"
  get "admin/applications" => "admin#applications"
  get "admin/dues" => "admin#dues"

  patch "admin/approve" => "admin#approve"
  patch "admin/reject" => "admin#reject"

  post "admin/setup_complete" => "admin#setup_complete"
  post "admin/save_membership_note" => "admin#save_membership_note"

  resources :applications, only: [:new, :show, :edit, :update]

  get "auth/:provider/callback" => "sessions#create"
  get "github_login" => "sessions#github"
  get "google_login" => "sessions#google"
  get "login" => "sessions#login"
  get "logout" => "sessions#destroy"
  get "auth/failure" => "sessions#failure"
  get "get_email" => "sessions#get_email"
  post "confirm_email" => "sessions#confirm_email"

  post "add_github_auth" => "authentications#add_github_auth"
  post "add_google_auth" => "authentications#add_google_auth"

  get "public_members" => "api#public_members"
  get "configurations" => "api#configurations"

  mount StripeEvent::Engine => "/stripe"

  # Programmatic doorbell handling routes. Scoped under /doorbell path.
  scope path: "doorbell", as: "doorbell", defaults: { format: "xml" } do
    root to: "doorbell#welcome"
    get "sms" => "doorbell#sms"
    get "gather-ismember" => "doorbell#gather_ismember"
    get "gather-keycode" => "doorbell#gather_keycode"
  end
end
