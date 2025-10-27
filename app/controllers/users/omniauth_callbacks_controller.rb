class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  # Google認証後の処理を担当するアクション
  def google_oauth2
    # Userモデルで定義したメソッドを呼び出し、ユーザー情報を取得または作成
    @user = User.from_omniauth(request.env["omniauth.auth"])
      
    if @user.persisted?
        # 認証成功
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Google"
        # サインイン処理
        sign_in_and_redirect @user, event: :authentication
    else
        # 認証失敗または情報不足
        session["devise.google_data"] = request.env["omniauth.auth"].except("extra") # 安全のため余分な情報を除外
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  # Deviseのヘルパーメソッド（認証失敗時のリダイレクト先をオーバーライド）
  def failure
    redirect_to root_path
  end
end