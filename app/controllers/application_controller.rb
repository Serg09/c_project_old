class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    return author_path(resource) if resource.is_a? Author
    return admin_root_path if resource.is_a? Administrator
    super resource
  end

  def current_ability
    @current_ability ||= initialize_ability
  end

  def initialize_ability
    return AdministratorAbility.new if administrator_signed_in?
    Ability.new current_author
  end

  def access_denied_redirect_path
    case
    when author_signed_in?
      author_root_path
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

  def authenticate_user!
    return if administrator_signed_in?
    authenticate_author!
  end

  def not_found!
    raise ActionController::RoutingError.new('Not Found')
  end
end
