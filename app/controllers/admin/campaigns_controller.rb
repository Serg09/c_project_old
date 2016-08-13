class Admin::CampaignsController < ApplicationController
  layout 'admin'
  before_filter :authenticate_administrator!
  before_filter :load_campaign, only: [:show]

  def index
    @campaigns = (params[:status] || 'current') == 'current' ?
      Campaign.current :
      Campaign.past
    @campaigns = @campaigns.paginate(page: params[:page])
  end

  def show
    @contributions = @campaign.
      contributions.
      order('created_at desc').
      paginate(page: params[:page], per_page: 5)
  end

  private

  def load_campaign
    @campaign = Campaign.find(params[:id])
  end
end
