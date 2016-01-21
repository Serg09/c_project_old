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

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to author_root_path, alert: exception.message
  end
end
