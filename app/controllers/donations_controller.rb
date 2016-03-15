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
    @donation_creator = DonationCreator.new(donation_attributes)
    flash[:notice] = 'Your donation was created successfully.' if @donation_creator.create!
    respond_with @donation_creator, location: create_redirect_path
  end

  private

  def create_redirect_path
    @donation_creator.donation ? donation_path(@donation_creator.donation) : book_path(@campaign.book)
  end

  def donation_attributes
    params.require(:donation).permit(:amount,
                                     :email,
                                     :credit_card,
                                     :credit_card_type,
                                     :expiration_month,
                                     :expiration_year,
                                     :cvv,
                                     :first_name,
                                     :last_name,
                                     :address_1,
                                     :address_2,
                                     :city,
                                     :state,
                                     :postal_code).merge(campaign: @campaign)
  end

  def load_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end

  def load_donation
    @donation = Donation.find(params[:id])
  end
end
