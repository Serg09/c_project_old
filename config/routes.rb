Rails.application.routes.draw do
  devise_for :administrators, path: 'admin', controllers: {
    sessions: 'admin/sessions'
  }
  devise_for :authors, controllers: {
    sessions:      'authors/sessions',
    registrations: 'authors/registrations',
    confirmations: 'authors/confirmations'
  }

  resources :inquiries, only: [:new, :create]
  resources :authors, only: [:show, :edit, :update, :index] do
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
    resources :donations, only: [:new, :create, :index]
    member do
      patch :pause
      patch :unpause
    end
  end
  resources :donations, only: [:show]

  namespace :admin do
    resources :inquiries, only: [:index, :show] do
      member do
        patch :archive
      end
    end
    resources :authors, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
      end
    end
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
  get 'pages/sign_up_confirmation'
  get 'pages/account_pending'

  get 'authors', to: 'authors#show', as: :author_root
  get 'admin', to: 'admin/authors#index', as: :admin_root
  root to: 'pages#welcome'
end
