class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]
  before_filter :ensure_sign_in_allowed, only: [:new, :create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    return unless ensure_user_approved!
    super
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end

  private

  def ensure_user_approved!
    user = User.find_by(email: sign_in_params[:email])
    case user.try(:status)
    when User.PENDING
      flash[:warning] = 'Unable to sign in. Your account is still pending approval by the administrator.'
      redirect_to pages_account_pending_path
      return false
    when User.REJECTED
      redirect_to new_user_session_path, alert: 'Unable to sign in. Your account has been rejected by the administrator.'
      return false
    end
    true
  end
end
