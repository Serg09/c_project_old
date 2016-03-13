class DonationsController < ApplicationController
  before_filter :authenticate_author!, only: [:index, :show]
  before_filter :load_campaign, only: [:index, :new, :create]
  before_filter :load_donation, only: [:show]

  respond_to :html

  def index
    authorize! :update, @campaign
  end

  def show
    authorize! :show, @donation
  end

  def new
  end

  def create
    # TODO Need to create the payment first
    @donation = @campaign.donations.new(donation_attributes)
    flash[:notice] = 'Your donation was created successfully.' if @donation.save
    respond_with @donation
  end

  private

  def donation_attributes
    params.require(:donation).permit(:amount, :email)
  end

  def load_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end

  def load_donation
    @donation = Donation.find(params[:id])
  end
end
