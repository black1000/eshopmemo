class User < ApplicationRecord
    # :omniauthable と omniauth_providers: [:google_oauth2] を追加
    devise  :database_authenticatable, :registerable,
            :recoverable, :rememberable, :validatable,
            :omniauthable, omniauth_providers: [:google_oauth2]

    # Google認証からのデータを受け取り、ユーザーを検索または新規作成する
    def self.from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.email = auth.info.email
        # Google認証ユーザーはパスワード認証を使わないため、ランダムな値を設定
        user.password = Devise.friendly_token[0, 20]
        user.name = auth.info.name   # nameカラムにGoogleの表示名を設定
        # user.image = auth.info.image # 画像URLも保存できる
    end
   end

    # 通常のパスワードログインを試みるユーザーが、OmniAuthで登録されたユーザーと同じメールアドレスで登録しようとした場合のエラーを回避
    def email_required?
        super && provider.blank?
    end

    def password_required?
        super && provider.blank?
    end

    # ユーザー名が設定されていない場合はメールアドレスの@以前を使用
    def display_name
        name.presence || email.split('@').first
    end
end