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
    @donation_creator = DonationCreator.new(campaign: @campaign)
  end

  def create
    @donation_creator = DonationCreator.new(donation_attributes)
    respond_with(@donation_creator, location: book_path(@campaign.book_id)) do |format|
      if @donation_creator.create!
        flash[:notice] = 'Your donation has been saved successfully. Expect to receive a confirmation email with all of the details.'
        send_notification_emails @donation_creator.donation
      else
        set_error_flash
        format.html { render :new }
      end
    end
  end

  private

  def donation_attributes
    params.require(:donation).permit(:amount,
                                     :reward_id,
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
                                     :postal_code).merge(campaign: @campaign,
                                                         ip_address: request.remote_ip,
                                                         user_agent: request.headers['HTTP_USER_AGENT'])
  end

  def load_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end

  def load_donation
    @donation = Donation.find(params[:id])
  end

  def send_notification_emails(donation)
    DonationMailer.donation_receipt(donation).deliver_now
    DonationMailer.donation_received_notify_author(donation).deliver_now
    DonationMailer.donation_received_notify_administrator(donation).deliver_now
  end

  def set_error_flash
    if Rails.env.production?
      flash.now[:alert] = 'We were unable to save your donation. Please try again later.'
    else
      flash.now[:alert] = "We were unable to save your donation. #{@donation_creator.exceptions.to_sentence}"
    end
  end
end
