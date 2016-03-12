module CampaignsHelper
  def campaign_row_class(campaign)
    if campaign.active?
      'success'
    elsif campaign.paused?
      'warning'
    else
      'danger'
    end
  end
end
