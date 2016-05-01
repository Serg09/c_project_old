class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    return user_path(resource) if resource.is_a? User
    return admin_root_path if resource.is_a? Administrator
    super resource
  end

  def current_ability
    @current_ability ||= initialize_ability
  end

  def initialize_ability
    return AdministratorAbility.new if administrator_signed_in?
    Ability.new current_user
  end

  def ensure_sign_in_allowed
    not_found! if AppSetting.sign_in_disabled?
  end

  def access_denied_redirect_path
    case
    when user_signed_in?
      user_root_path
    when administrator_signed_in?
      admin_root_path
    else
      root_path
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to access_denied_redirect_path, alert: exception.message
  end

  protected

  def not_found!
    raise ActionController::RoutingError.new('Not Found')
  end

  # Redirects to the home page so as not to give away the admin sign in path
  def authenticate_administrator!
    redirect_to root_path unless administrator_signed_in?
  end
end
