module CampaignsHelper
  def campaign_row_class(campaign)
    if campaign.active?
      'success'
    elsif campaign.unstarted?
      'warning'
    end
  end
end
