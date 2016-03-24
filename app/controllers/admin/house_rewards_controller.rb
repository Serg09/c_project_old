class Admin::HouseRewardsController < ApplicationController
  layout 'admin'

  before_filter :safe_authenticate_administrator!
  before_filter :load_house_reward, only: [:edit, :update, :destroy, :show]

  respond_to :html

  def index
    @house_rewards = HouseReward.all
  end

  def new
    @house_reward = HouseReward.new
  end

  def create
    @house_reward = HouseReward.new house_reward_params
    flash[:notice] = 'The reward was created successfully.' if @house_reward.save
    respond_with @house_reward, location: admin_house_rewards_path
  end

  def edit
  end

  def update
    @house_reward.update_attributes house_reward_params
    flash[:notice] = 'The reward was updated successfully.' if @house_reward.save
    respond_with @house_reward, location: admin_house_rewards_path
  end

  def show
  end

  def destroy
    flash[:notice] = 'The reward was removed successfully.' if @house_reward.destroy
    respond_with @house_reward, location: admin_house_rewards_path
  end

  private

  def load_house_reward
    @house_reward = HouseReward.find(params[:id])
  end

  def house_reward_params
    params.require(:house_reward).permit(:description, :physical_address_required)
  end
end
