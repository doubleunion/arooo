Doubleunion::Application.routes.draw do
  root :to => 'static#index'

  namespace :members do
    root :to => 'users#index'
    resources :users, :only => [:index, :show, :edit, :update] do
      get 'setup' => "users#setup"
      patch 'setup' => "users#finalize"
      get 'dues' => "users#dues"
      patch 'dues' => "users#update_dues"
    end
    resources :votes, :only => :create

    resources :applications, :only => [:index, :show] do
      resources :comments, :only => :create
      post 'sponsor' => "applications#sponsor"
    end

    resources :caches, :only => :index do
      post :expire, :on => :collection
    end
  end

  get 'admin/new_members' => 'admin#new_members'
  get 'admin/applications' => 'admin#applications'
  get 'admin/members' => 'admin#members'

  patch 'admin/approve' => 'admin#approve'
  patch 'admin/reject' => 'admin#reject'

  post 'admin/setup_complete' => 'admin#setup_complete'
  post 'admin/save_membership_note' => 'admin#save_membership_note'

  patch 'admin/add_key_member' => 'admin#add_key_member'
  patch 'admin/revoke_key_member' => 'admin#revoke_key_member'
  patch 'admin/revoke_membership' => 'admin#revoke_membership'

  resources :tumblr_posts, :only => [:index, :show], :path => 'blog'

  resources :applications, :only => [:new, :show, :edit, :update]

  get 'auth/:provider/callback' => 'sessions#create'
  get 'login' => 'sessions#new'
  get 'logout' => 'sessions#destroy'
  get 'auth/failure' => 'sessions#failure'

  get 'membership', :to => 'static#membership'
  get 'policies',   :to => 'static#policies'
  get 'press',      :to => 'static#press'
  get 'support',    :to => 'static#support'
  get 'supporters', :to => 'static#supporters'
  get 'visit',      :to => 'static#visit'

  get 'base_assumptions', :to => 'static#base_assumptions'
end
