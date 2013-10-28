Doubleunion::Application.routes.draw do
  root :to => "home#index"

  namespace :admin do
    root :to => 'admin#index'
    resources :users, :only => :index
  end

  get '/auth/:provider/callback' => 'sessions#create'
  get '/login' => 'sessions#new'
  get '/logout' => 'sessions#destroy'
  get '/auth/failure' => 'sessions#failure'

  get 'blog',       :to => 'blog#index'
  get 'membership', :to => 'membership#index'

  get 'support',  :to => 'static#support'
  get 'press',    :to => 'static#press'
  get 'policies', :to => 'static#policies'
end
