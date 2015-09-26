Rails.application.routes.draw do
  devise_for :users
  get 'pages/welcome'
  get 'pages/faq'
  get 'pages/about_us'
  root to: 'pages#welcome'
end
