class PagesController < ApplicationController
  def welcome
    @subscriber = Subscriber.new if AppSetting.sign_in_disabled?
  end
end
