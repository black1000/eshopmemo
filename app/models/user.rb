class User < ApplicationRecord
has_many :items, dependent: :destroy
has_many :tags, dependent: :destroy
has_many :reminders, dependent: :destroy

  # :omniauthable に :omniauth_providers を指定してGoogleログイン対応
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  # GoogleからのOAuth情報をもとにユーザーを取得・作成
  def self.from_omniauth(auth)
    # provider と uid で既存ユーザーを探す
    user = find_by(provider: auth.provider, uid: auth.uid)

    # 存在しない場合は新規作成
    unless user
      user = create(
        provider: auth.provider,
        uid: auth.uid,
        name: auth.info.name,
        email: auth.info.email,
        password: Devise.friendly_token[0, 20]  # ランダムパスワード
      )
    end

    user
  end
end
