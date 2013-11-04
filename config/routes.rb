Doubleunion::Application.routes.draw do
  root :to => "home#index"

  namespace :admin do
    root :to => 'admin#index'
    resources :users, :only => :index
  end

  resources :tumblr_posts, :only => [:index, :show], :path => 'blog'

  get '/auth/:provider/callback' => 'sessions#create'
  get '/login' => 'sessions#new'
  get '/logout' => 'sessions#destroy'
  get '/auth/failure' => 'sessions#failure'

  get 'membership', :to => 'membership#index'

  get 'support',    :to => 'static#support'
  get 'press',      :to => 'static#press'
  get 'policies',   :to => 'static#policies'
  get 'supporters', :to => 'static#supporters'
  get 'visit',      :to => 'static#visit'
  get 'base_assumptions', :to => 'static#base_assumptions'
end
