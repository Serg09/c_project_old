class ContributionsController < ApplicationController
  before_filter :authenticate_user!, only: [:index, :show]
  before_filter :load_campaign, only: [:index, :new, :create]
  before_filter :load_contribution, only: [:show]

  respond_to :html

  def index
    authorize! :update, @campaign
  end

  def show
    authorize! :show, @contribution
  end

  def new
    @contribution_creator = ContributionCreator.new(campaign: @campaign)
  end

  def create
    @contribution_creator = ContributionCreator.new(contribution_attributes)
    respond_with(@contribution_creator, location: book_path(@campaign.book_id)) do |format|
      if @contribution_creator.create!
        flash[:notice] = 'Your contribution has been saved successfully. Expect to receive a confirmation email with all of the details.'
        send_notification_emails @contribution_creator.contribution
      else
        set_error_flash
        format.html { render :new }
      end
    end
  end

  private

  def contribution_attributes
    params.require(:contribution).permit(:amount,
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

  def load_contribution
    @contribution = Contribution.find(params[:id])
  end

  def send_notification_emails(contribution)
    # TODO Move this to resque jobs
    ContributionMailer.contribution_receipt(contribution).deliver_now
    ContributionMailer.contribution_received_notify_author(contribution).deliver_now unless contribution.campaign.author.unsubscribed?
    AdminMailer.contribution_received(contribution).deliver_now
    if campaign_just_succeeded?
      CampaignMailer.succeeded(contribution.campaign).deliver_now unless contribution.campaign.author.unsubscribed?
      AdminMailer.campaign_succeeded(contribution.campaign).deliver_now
      contribution.campaign.success_notification_sent_at = DateTime.now
      contribution.campaign.save!
    end
  end

  def campaign_just_succeeded?
    @campaign.target_amount_reached? && !@campaign.success_notification_sent?
  end

  def set_error_flash
    if Rails.env.production?
      flash.now[:alert] = 'We were unable to save your contribution. Please try again later.'
    else
      flash.now[:alert] = "We were unable to save your contribution. #{@contribution_creator.exceptions.to_sentence}"
    end
  end
end
