Doubleunion::Application.routes.draw do
  root to: 'sessions#login'

  namespace :members do
    root to: 'users#index'

    resources :users, only: [:index, :show, :edit, :update] do
      get 'setup' => "users#setup"
      patch 'setup' => "users#finalize"

      resource :dues, only: [:show, :update]
      delete 'cancel' => "dues#cancel"
      post 'scholarship_request' => "dues#scholarship_request"

      resource :key_members, only: [:edit, :update]
      resource :voting_members, only: [:edit, :update]
    end
    resources :votes, only: [:create, :destroy]

    resources :applications, only: [:index, :show] do
      resources :comments, only: :create
      post 'sponsor' => "applications#sponsor"
    end

    resources :caches, only: :index do
      post :expire, on: :collection
    end
  end

  namespace :admin do
    resource :exceptions, only: :show
    resources :memberships, only: [:index, :update]
    patch "memberships/:id/change_membership_state" => "memberships#change_membership_state", as: "change_membership_state"
  end

  get 'admin/new_members' => 'admin#new_members'
  get 'admin/applications' => 'admin#applications'
  get 'admin/dues' => 'admin#dues'

  patch 'admin/approve' => 'admin#approve'
  patch 'admin/reject' => 'admin#reject'

  post 'admin/setup_complete' => 'admin#setup_complete'
  post 'admin/save_membership_note' => 'admin#save_membership_note'

  resources :applications, only: [:new, :show, :edit, :update]

  get 'auth/:provider/callback' => 'sessions#create'
  get 'github_login' => 'sessions#github'
  get 'google_login' => 'sessions#google'
  get 'login' => 'sessions#login'
  get 'logout' => 'sessions#destroy'
  get 'auth/failure' => 'sessions#failure'
  get 'get_email' => 'sessions#get_email'
  post 'confirm_email' => 'sessions#confirm_email'

  post 'add_github_auth' => 'authentications#add_github_auth'
  post 'add_google_auth' => 'authentications#add_google_auth'

  get 'public_members' => 'api#public_members'
  get 'configurations' => 'api#configurations'

  mount StripeEvent::Engine => '/stripe'
end
