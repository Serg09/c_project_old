class CampaignsController < ApplicationController
  include ApplicationHelper

  before_filter :authenticate_user!
  before_filter :load_campaign, except: [:index, :new, :create]
  before_filter :load_book, only: [:index, :new, :create]

  respond_to :html

  def index
    authorize! :update, @book
    @campaigns = @book.campaigns
  end

  def new
    @campaign = @book.campaigns.new
    authorize! :create, @campaign
  end

  def create
    @campaign = @book.campaigns.new(campaign_params)
    authorize! :create, @campaign
    flash[:notice] = "The campaign was created successfully." if @campaign.save
    respond_with @campaign, location: edit_campaign_path(@campaign)
  end

  def show
    authorize! :show, @campaign
    @contributions = @campaign.contributions.paginate(page: params[:contributions_page], per_page: 8)
    @total_pledged = @campaign.contributions.sum(:amount)
    @total_collected = @campaign.contributions.collected.sum(:amount)
  end

  def edit
    authorize! :update, @campaign
  end

  def update
    authorize! :update, @campaign
    @campaign.update_attributes campaign_params
    flash[:notice] = "The campaign was updated successfully." if @campaign.save
    respond_with @campaign, location: book_campaigns_path(@campaign.book)
  end

  def start
    authorize! :update, @campaign

    @campaign.agree_to_terms = user_agreed_to_terms?
    if !@campaign.agree_to_terms?
      flash.now[:alert] = 'You must agree to the terms to continue.'
      render :terms
    elsif !@campaign.target_date_in_range?
      redirect_to edit_campaign_path(@campaign), alert: 'The target date must be at least 30 days in the future.'
    elsif @campaign.start!
      redirect_to campaign_path(@campaign), notice: 'The campaign was started successfully.'
    else
      redirect_to edit_campaign_path(@campaign), alert: 'We were unable to start the campaign.'
    end
  end

  def prolong
    authorize! :update, @campaign
    if @campaign.prolonged?
      flash[:alert] = 'This campaign has already been extended and cannot be extended again.'
    else
      flash[:notice] = 'The campaign was extended successfully.' if @campaign.prolong
    end
    redirect_to campaign_path(@campaign)
  end

  def collect
    authorize! :update, @campaign
    if @campaign.collect!
      flash[:notice] = 'The campaign was closed successfully.'
      CampaignMailer.collecting(@campaign).deliver_now unless @campaign.author.unsubscribed?
    end
    redirect_to campaign_path(@campaign)
  end

  def cancel
    authorize! :update, @campaign
    if @campaign.cancel!
      flash[:notice] = 'The campaign was cancelled successfully.'
      CampaignMailer.cancelled(@campaign).deliver_now unless @campaign.author.unsubscribed?
    end
    redirect_to campaign_path(@campaign)
  end

  def destroy
    authorize! :destroy, @campaign
    flash[:notice] = "The campaign was removed successfully." if @campaign.destroy
    respond_with @campaign, location: book_campaigns_path(@campaign.book)
  end

  def terms
    authorize! :update, @campaign
    @form_url = start_campaign_path(@campaign)
  end

  private

  def campaign_params
    params.require(:campaign).
      permit(:target_date, :target_amount).
      tap do |params|
        params['target_date'] = Chronic.parse(params['target_date'])
    end
  end

  def load_book
    @book = Book.find(params[:book_id])
  end

  def load_campaign
    @campaign = Campaign.find(params[:id])
    @book = @campaign.book
  end

  def user_agreed_to_terms?
    campaign_params = params[:campaign]
    return false unless campaign_params

    keys = [:agree_to_terms]
    keys << :agree_to_terms_2 if @campaign.has_house_rewards?
    keys.map{|k| html_true(campaign_params[k])}.all?
  end
end
