class ContributionsController < ApplicationController
  before_filter :authenticate_user!, only: [:index, :show]
  before_filter :load_campaign, only: [:index, :new, :create]
  before_filter :load_contribution, only: [:show, :reward, :set_reward, :payment, :pay]
  before_filter :validate_state!, only: [:reward, :set_reward, :payment, :pay]
  before_filter :load_reward, only: [:create, :set_reward]

  respond_to :html

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
    if @contribution.save
      if @reward
        redirect_to payment_contribution_path(@contribution)
      else
        redirect_to reward_contribution_path(@contribution)
      end
    else
      render :new
    end
  end

  def reward
  end

  def set_reward
    redirect_to payment_contribution_path(@contribution, reward_id: selected_reward_id)
  end

  def payment
    @reward_id = selected_reward_id
  end

  def pay
    @contribution.update_attributes contribution_params
    if @contribution.save
      @payment = @contribution.payments.new payment_params
      if @payment.save && @contribution.collect!
        redirect_to book_path(@campaign.book_id)
      else
        flash[:alert] = "Unable to process the payment."
        render :payment
      end
    else
      flash[:alert] = "Unable to save the contribution."
      render :payment
    end
  end

  private

  def fulfillment_attributes
    params.require(:fulfillment).permit(
      :reward_id,
      :address1,
      :address2,
      :city,
      :state,
      :postal_code
    )
  end

  def payment_params
    params.require(:payment).permit(
      :credit_card_number,
      :credit_card_type,
      :expiration_month,
      :expiration_year,
      :cvv,
      :billing_address_1,
      :billing_address_2,
      :billing_city,
      :billing_state,
      :billing_postal_code,
      :billing_country_code
    )
  end

  def contribution_params
    {
      ip_address: request.remote_ip,
      user_agent: request.headers['HTTP_USER_AGENT']
    }.with_indifferent_access.tap do |h|
      if params[:contribution].present?
        h.merge! params.require(:contribution).permit(:amount, :email)
      end
      if h[:amount].blank? && @reward.present?
        h[:amount] = @reward.minimum_contribution
      end
    end
  end

  def load_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end

  def load_contribution
    @contribution = Contribution.find(params[:id])
    @campaign = @contribution.campaign
  end

  def load_reward
    id = params[:fulfillment].try(:[], :reward_id)
    @reward = Reward.find(id) if id
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

  def selected_reward_id
    params[:fulfillment].try(:[], :reward_id)
  end

  def validate_state!
    unless @contribution.incipient?
      redirect_to user_root_path, alert: "The specified contribution cannot be modified"
    end
  end
end
