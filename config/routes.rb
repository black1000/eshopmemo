Rails.application.routes.draw do

    # Deviseのルーティングに、OmniAuthのコールバックコントローラを指定する設定を追加
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }

  # 商品関連のルーティング
  resources :items do
    collection do
      get 'tag/:tag', to: 'items#tag', as: :tagged_items 
      get :reminders 
      get :memos_on_date
    end
  end

  get 'tags', to: 'items#tags', as: :tags
  
  # トップページ
  root "top#index"

  get "up" => "rails/health#show", as: :rails_health_check
end