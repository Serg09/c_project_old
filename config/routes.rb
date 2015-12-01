Rails.application.routes.draw do
  devise_for :users
  get 'pages/welcome'
  get 'pages/package_pricing'
  get 'pages/a_la_carte_pricing'
  get 'pages/faqs'
  get 'pages/about_us'
  get 'pages/contact_us'
  root to: 'pages#welcome'
end
