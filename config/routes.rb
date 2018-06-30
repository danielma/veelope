require "sidekiq/web"

Rails.application.routes.draw do
  # not authenticated

  resource :session, only: %i(new create destroy)
  resources :signups, only: %i(new create)

  # authenticated

  resource :account, only: %i(edit update)
  resources :users
  resources :designations
  resources :bank_transactions, path: "transactions", only: %i(index new create) do
    get :inbox, on: :collection
  end
  resources :merges, only: %i(index create)
  resources :envelopes do
    resources :bank_transactions, path: "transactions", only: %(index)
  end
  resources :envelope_groups
  resources :bank_accounts, only: %i(index edit update) do
    resources :bank_transactions, path: "transactions", shallow: true, only: %i(index new create edit update destroy)
  end
  resources :bank_connections, only: %i(index show new create destroy update) do
    post :refresh, on: :member
  end
  resources :transfers, only: %i(new create)
  resources :fundings, only: %i(new create)

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :bank_transactions, only: %i(create)
      resources :ofxs, only: %i(create)
    end
  end

  mount Sidekiq::Web => "/sidekiq", constraints: SidekiqConstraint.new

  root to: "dashboards#show"
end
