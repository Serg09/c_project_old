class RewardsController < ApplicationController
  respond_to :html

  before_filter :authenticate_user!
  before_filter :load_campaign, only: [:new, :create]
  before_filter :load_reward, only: [:edit, :update, :destroy]

  def new
    @reward = @campaign.rewards.new
    authorize! :create, @reward
  end

  def create
    @reward = @campaign.rewards.new reward_params
    authorize! :create, @reward
    flash[:notice] = 'The reward was created successfully.' if @reward.save
    respond_with @reward, location: edit_campaign_path(@campaign)
  end

  def edit
    authorize! :update, @reward
  end

  def update
    authorize! :update, @reward
    @reward.update_attributes reward_params
    flash[:notice] = 'The reward was updated successfully.' if @reward.save
    respond_with @reward, location: edit_campaign_path(@campaign)
  end

  def destroy
    authorize! :destroy, @reward
    flash[:notice] = 'The reward was removed successfully.' if @reward.destroy
    redirect_to edit_campaign_path(@campaign)
  end

  private

  def load_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end

  def load_reward
    @reward = Reward.find(params[:id])
    @campaign = @reward.campaign
  end

  def reward_params
    params.require(:reward).permit(:description,
                                   :long_description,
                                   :photo_file,
                                   :minimum_contribution,
                                   :physical_address_required,
                                   :house_reward_id)
  end
end
