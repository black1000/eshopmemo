class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    auth = request.env["omniauth.auth"]

  if auth.blank?
    redirect_to unauthenticated_root_path, 
    alert: t("devise.omniauth_callbacks.google_oauth2.failure")
    return
  end

    @user = User.from_omniauth(auth)

    if @user.persisted?
      flash[:notice] = t("devise.omniauth_callbacks.google_oauth2.success")
      flash[:ga_event] = { name: "login", params: { method: "google" } }
      sign_in_and_redirect @user, event: :authentication
    else
      session["devise.google_data"] = request.env["omniauth.auth"].except("extra")
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to unauthenticated_root_path,
    alert: t("devise.omniauth_callbacks.google_oauth2.failure")
  end


  def after_sign_in_path_for(resource)
    items_path  # 商品一覧ページ
  end
end
