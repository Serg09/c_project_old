class Admin::DonationsController < ApplicationController
  before_filter :safe_authenticate_administrator!

  layout 'admin'
  respond_to :html

  def unfulfilled
  end
end
