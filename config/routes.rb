Doubleunion::Application.routes.draw do
  root :to => 'static#index'

  namespace :admin do
    root :to => 'users#index'
    resources :users, :only => [:index, :show, :edit, :update]
    resources :votes, :only => :create

    resources :applications, :only => :show do
      resources :comments, :only => :create
      post 'sponsor' => "applications#sponsor"
    end

    resources :caches, :only => :index do
      post :expire, :on => :collection
    end
  end

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

  #get 'base_assumptions', :to => 'static#base_assumptions'
end
