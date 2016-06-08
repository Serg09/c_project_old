class CampaignsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_campaign, only: [:show, :edit, :update, :destroy, :start, :collect, :cancel, :prolong]
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
    @donations = @campaign.donations.paginate(page: params[:donations_page], per_page: 8)
    @total_pledged = @campaign.donations.sum(:amount)
    @total_collected = @campaign.donations.collected.sum(:amount)
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
    if @campaign.target_date_in_range?
      flash[:notice] = 'The campaign was started successfully.' if @campaign.start
      redirect_to campaign_path(@campaign)
    else
      redirect_to book_campaigns_path(@book), alert: 'The target date must be at least 30 days in the future.'
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
    if @campaign.collect
      flash[:notice] = 'The campaign was closed successfully.'
      CampaignMailer.collecting(@campaign).deliver_now unless @campaign.author.unsubscribed?
    end
    redirect_to campaign_path(@campaign)
  end

  def cancel
    authorize! :update, @campaign
    if @campaign.cancel
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
end
