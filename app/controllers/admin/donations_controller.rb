class Admin::DonationsController < ApplicationController
  before_filter :safe_authenticate_administrator!

  layout 'admin'
  respond_to :html

  def unfulfilled
    @donations = Donation.
      where('donations.reward_id is not null').
      joins(:campaign).
      where('campaigns.state' => 'collected').
      joins(:reward).
      where('rewards.house_reward_id is not null')
  end
end
