class CampaignsController < ApplicationController
  before_filter :authenticate_author!
  before_filter :load_campaign, only: [:show, :edit, :update, :destroy, :pause, :unpause]
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
    respond_with @campaign, location: book_campaigns_path(@book)
  end

  def show
    authorize! :show, @campaign
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

  def pause
    authorize! :update, @campaign
    @campaign.paused = true
    flash[:notice] = 'The campaign was paused successfully.' if @campaign.save
    redirect_to books_path
  end

  def unpause
    authorize! :update, @campaign
    @campaign.paused = false
    flash[:notice] = 'The campaign was unpaused successfully.' if @campaign.save
    redirect_to books_path
  end

  def destroy
    authorize! :destroy, @campaign
    flash[:notice] = "The campaign was removed successfully." if @campaign.destroy
    respond_with @campaign, location: book_campaigns_path(@campaign.book)
  end

  private

  def campaign_params
    params.require(:campaign).
      permit(:target_date, :target_amount, :paused).
      tap do |params|
        params['target_date'] = Chronic.parse(params['target_date'])
    end
  end

  def load_book
    @book = current_author.books.find(params[:book_id])
  end

  def load_campaign
    @campaign = current_author.campaigns.find(params[:id])
  end
end
