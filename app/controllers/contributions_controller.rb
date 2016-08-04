class ContributionsController < ApplicationController
  before_filter :authenticate_user!, only: [:index, :show]
  before_filter :load_campaign, only: [:index, :new, :create]
  before_filter :load_contribution, only: [:show, :edit, :update]
  before_filter :load_reward, only: [:create]

  respond_to :html, :json

  def index
    authorize! :update, @campaign
  end

  def show
    authorize! :show, @contribution
  end

  def new
    @contribution = @campaign.contributions.new
    @fulfillment = PhysicalFulfillment.new # TODO Need physical or electronic here
  end

  def create
    @contribution = @campaign.contributions.new contribution_params
    @fulfillment = build_fulfillment
    @contribution.save
    if @contribution.save
      if @fulfillment
        unless @fulfillment.save
          Rails.logger.warn "Unable to save the the fulfillment #{@fulfillment.inspect}"
        end
      end
      send_notification_emails
    else
      Rails.logger.error "Unable to save the contribution #{@contribution.inspect}"
    end
    respond_with @contribution
  end

  private

  def build_fulfillment
    if @reward.nil?
      nil
    elsif @reward.physical_address_required?
      PhysicalFulfillment.new physical_fulfillment_params
    else
      ElectronicFulfillment.new electronic_fulfillment_params
    end
  end

  def physical_fulfillment_params
    params.require(:fulfillment).permit(
      :reward_id,
      :first_name,
      :last_name,
      :address1,
      :address2,
      :city,
      :state,
      :postal_code
    ). merge(contribution: @contribution,
             country_code: 'US')
  end

  def electronic_fulfillment_params
    params.require(:fulfillment).permit(
      :reward_id
    ).merge(contribution: @contribution,
            email: @contribution.email)
  end

  def contribution_params
    params.require(:contribution).
      permit(:amount, :email).
      merge ip_address: request.remote_ip,
            user_agent: request.headers['HTTP_USER_AGENT']
  end

  def load_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end

  def load_contribution
    @contribution = Contribution.find(params[:id])
    @campaign = @contribution.campaign
  end

  def load_reward
    fulfillment = params[:fulfillment]
    if fulfillment
      @reward = Reward.find(fulfillment[:reward_id])
    end
  end

  def send_notification_emails
    # TODO Move this to resque jobs
    ContributionMailer.contribution_receipt(@contribution).deliver_now
    ContributionMailer.contribution_received_notify_author(@contribution).deliver_now unless @contribution.campaign.author.unsubscribed?
    AdminMailer.contribution_received(@contribution).deliver_now
    if campaign_just_succeeded?
      CampaignMailer.succeeded(@contribution.campaign).deliver_now unless @contribution.campaign.author.unsubscribed?
      AdminMailer.campaign_succeeded(@contribution.campaign).deliver_now
      @contribution.campaign.success_notification_sent_at = DateTime.now
      @contribution.campaign.save!
    end
  end

  def campaign_just_succeeded?
    @campaign.target_amount_reached? && !@campaign.success_notification_sent?
  end
end
