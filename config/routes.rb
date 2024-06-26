require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :admins, controllers: {
    sessions: 'admin/sessions'
  }
  devise_for :customers, controllers: {
    sessions: 'customer/sessions',
    registrations: 'customer/registrations'
  }
  root to: 'pages#home'
  namespace :admin do
    root to: 'pages#home'
    resources :products, only: %i[index show new create edit update]
    resources :orders, only: %i[show update]
    resources :customers, only: %i[index show update]

    # sidekiq 管理画面
    authenticate :admin do
      mount Sidekiq::Web => '/sidekiq'
    end
  end

  scope module: :customer do
    resources :products, only: %i[index show]
    resources :cart_items, only: %i[index create destroy] do
      # MEMO: Cart_Itemsのidを含んだURLを扱えるようにする
      member do
        patch 'increase'
        patch 'decrease'
      end
    end

    # Stripe
    resources :checkouts, only: [:create] # Stripe | createアクションのみ
    resources :webhooks, only: [:create] # Stripe | createアクションのみ

    # success
    resources :orders, only: %i[index show] do
      collection do
        get 'success'
      end
    end

    # 退会
    resources :customers do
      collection do
        get 'confirm_withdraw'
        patch 'withdraw'
      end
    end
  end

  # 静的なページ
  get  'law_pages/privacy_policy'
  get  'law_pages/tokusho'
  get  'law_pages/terms'

  get '/up/', to: 'up#index', as: :up
  get '/up/databases', to: 'up#databases', as: :up_databases
end
