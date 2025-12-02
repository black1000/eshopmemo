class ApplicationController < ActionController::Base

  allow_browser versions: :modern

  # キャッシュ防止
  before_action :prevent_cache

  before_action :set_locale

  def prevent_cache
    response.headers["Cache-Control"] = "no-store"
  end

  def after_sign_out_path_for(resource_or_scope)
    flash[:notice] = t('devise.sessions.signed_out')
    unauthenticated_root_path
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    I18n.locale == I18n.default_locale ? {} : { locale: I18n.locale }
  end

end
