class Admin::CampaignsController < ApplicationController
  layout 'admin'
  before_filter :safe_authenticate_administrator!

  def index
    @campaigns = (params[:status] || 'current') == 'current' ?
      Campaign.current :
      Campaign.past
  end
end
