Rails.application.routes.draw do
  get "pages/terms", to: "pages#terms", as: "terms"
  get "pages/privacy", to: "pages#privacy", as: "privacy"
  get "pages/contact", to: "pages#contact", as: "contact"
  get "tutorial", to: "pages#tutorial"
  get "items/reminders_by_date/:date", to: "items#reminders_by_date", as: "reminders_by_date"
  get "pages/pwa", to: "pages#pwa"

  # Deviseのルーティングに、OmniAuthのコールバックコントローラを指定する設定を追加
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations"
  }

  devise_scope :user do
    get "/users/auth/failure", to: "users/omniauth_callbacks#failure"
  end

  get "tag/:id", to: "items#tag", as: :tag_items

  # 商品関連のルーティング
  resources :items do
    collection do
      get :reminders
      get :memos_on_date
      get :edit_multiple   # 複数商品の編集フォーム表示
      patch :update_multiple  # 複数商品の更新処理
    end

     member do
    post :create_reminder # 単一商品のリマインダー作成
  end
  end

  get "tags", to: "items#tags", as: :tags

  authenticated :user do
    root "items#index", as: :authenticated_root
  end

  # トップページ
  unauthenticated do
    root "top#index", as: :unauthenticated_root
  end

  get "up" => "rails/health#show", as: :rails_health_check

  get "/service-worker.js", to: proc { |env|
  [
    200,
    { "Content-Type" => "application/javascript" },
    [ File.read(Rails.root.join("public", "service-worker.js")) ]
  ]
}
end
