require 'resque_web'

Rails.application.routes.draw do

  namespace :admin do
  get 'payments/show'
  end

  mount ResqueWeb::Engine => '/resque_web'

  devise_for :administrators, path: 'admin', controllers: {
    sessions: 'admin/sessions'
  }
  devise_for :users, controllers: {
    sessions:      'users/sessions',
    registrations: 'users/registrations',
    confirmations: 'users/confirmations'
  }

  resources :inquiries, only: [:new, :create, :show]
  get '/unsubscribe/:token', to: 'users#unsubscribe',
                             as: :unsubscribe,
                             constraints: { token: /[a-z0-9]{8}(?:-[a-z0-9]{4}){3}-[a-z0-9]{12}/i }
  get '/profile/edit', to: 'users#edit',
                       as: :edit_profile
  resources :users, only: [:show, :edit, :update, :index] do
    resources :bios, only: [:new, :index, :create]
  end
  resources :bios, only: [:show, :edit, :update, :index, :create, :new]
  resources :books, only: [:index, :show, :edit, :update, :new, :create] do
    resources :book_versions, path: 'versions', only: [:new, :create, :index]
    resources :campaigns, only: [:index, :new, :create]
    collection do
      get :browse
    end
  end
  resources :book_versions, only: [:edit, :update, :show]
  resources :images, only: :show
  resources :campaigns, only: [:show, :edit, :update, :destroy] do
    resources :donations, only: [:new, :create]
    resources :rewards, only: [:new, :create]
    member do
      patch :start
      patch :collect
      patch :cancel
      patch :prolong
    end
  end
  resources :donations, only: [:show]
  resources :rewards, only: [:edit, :update, :destroy]
  resources :fulfillments, only: [:index] do
    member do
      patch :fulfill
    end
  end

  namespace :admin do
    resources :inquiries, only: [:index, :show] do
      member do
        patch :archive
      end
    end
    resources :users, only: [:index, :show]
    resources :bios, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :book_versions, only: [:show, :index] do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :campaigns, only: [:index, :show]
    resources :house_rewards
    resources :fulfillments, only: [:index] do
      member do
        patch :fulfill
      end
    end
    resources :payments, only: [:show]
  end

  get 'pages/welcome'
  get 'pages/package_pricing'
  get 'pages/a_la_carte_pricing'
  get 'pages/faqs'
  get 'pages/about_us'
  get 'pages/book_incubator'
  get 'pages/why'
  get 'pages/klososky'
  get 'pages/rewilding'
  get 'pages/discipling'
  get 'pages/predicament'
  get 'pages/covenant'
  get 'pages/piatt'

  get 'authors', to: 'bios#browse', as: :browse_authors
  get 'users', to: 'users#show', as: :user_root
  get 'admin', to: 'admin/users#index', as: :admin_root
  root to: 'pages#welcome'
end
