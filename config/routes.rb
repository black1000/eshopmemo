Rails.application.routes.draw do
  get "pages/terms", to: "pages#terms", as: "terms"
  get "pages/privacy", to: "pages#privacy", as: "privacy"
  get "pages/contact", to:"pages#contact", as: "contact"
  get "tutorial", to: "pages#tutorial"

    # Deviseのルーティングに、OmniAuthのコールバックコントローラを指定する設定を追加
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    registrations: "users/registrations"
  }

  get 'tag/:id', to: 'items#tag', as: :tag_items

  # 商品関連のルーティング
  resources :items do
    collection do
      get :reminders 
      get :memos_on_date
    end
  end

  get 'tags', to: 'items#tags', as: :tags
  
  # トップページ
  root "top#index"

  get "up" => "rails/health#show", as: :rails_health_check
end