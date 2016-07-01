module PagesHelper
  def show_subscriber_form?
    AppSetting.sign_in_disabled? && not_yet_subscribed?
  end

  def not_yet_subscribed?
    !html_true(cookies[:subscribed])
  end
end
