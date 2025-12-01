class ApplicationController < ActionController::Base

  allow_browser versions: :modern

  # キャッシュ防止
  before_action :prevent_cache

  def prevent_cache
    response.headers["Cache-Control"] = "no-store"
  end

  def after_sign_out_path_for(resource_or_scope)
    flash[:notice] = t('devise.sessions.signed_out')
    unauthenticated_root_path
  end
end
