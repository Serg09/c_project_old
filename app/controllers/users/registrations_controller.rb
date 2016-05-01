class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_sign_up_params, only: [:create]
  before_filter :ensure_sign_in_allowed, only: [:new, :create]
# before_filter :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    super do |resource|
      if resource.valid?
        flash[:notice] = 'Your request for access has been accepted.'
        UserMailer.new_user_notification(resource).deliver_now
      else
        flash[:alert] = 'We were unable to save your registration.'
      end
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    [:username,
     :first_name,
     :last_name,
     :phone_number,
     :contactable,
     :package_id].each do |a|
       devise_parameter_sanitizer.for(:sign_up) << a
     end
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  def after_inactive_sign_up_path_for(resource)
    pages_sign_up_confirmation_path
  end
end
