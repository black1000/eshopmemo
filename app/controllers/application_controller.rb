class ApplicationController < ActionController::Base
  allow_browser versions: :modern

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
    I18n.locale = params[:locale] || session[:locale] || I18n.default_locale
    session[:locale] = I18n.locale
  end

  def default_url_options
    { locale: I18n.locale }.merge(super)
  end
end
