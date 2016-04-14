module CampaignsHelper
  def campaign_row_class(campaign)
    if campaign.active? && !campaign.expired?
      'success'
    end
  end
end
