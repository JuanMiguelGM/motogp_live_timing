# frozen_string_literal: true

Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  root 'dashboard#show'

  resources :events, only: %i[index show]

  resources :sessions, only: [:show] do
    member do
      get :timing_data
      get :positions
    end
  end

  namespace :api do
    get 'session_status', to: 'session_status#show'
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
