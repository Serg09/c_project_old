Rails.application.routes.draw do
  devise_for :administrators, path: 'admin'
  devise_for :authors, controllers: {
    sessions:      'authors/sessions',
    registrations: 'authors/registrations',
    confirmations: 'authors/confirmations'
  }

  resources :inquiries, only: [:new, :create]
  resources :authors, only: [:show, :edit, :update]

  get 'pages/welcome'
  get 'pages/package_pricing'
  get 'pages/a_la_carte_pricing'
  get 'pages/faqs'
  get 'pages/about_us'
  get 'pages/book_incubator'
  get 'pages/why'
  get 'pages/books'
  get 'pages/klososky'
  get 'pages/rewilding'
  get 'pages/discipling'
  get 'pages/predicament'
  get 'pages/covenant'
  get 'pages/piatt'
  get 'pages/sign_up_confirmation'
  get 'pages/account_pending'

  get 'authors', to: 'authors#show', as: :author_root
  root to: 'pages#welcome'
end
