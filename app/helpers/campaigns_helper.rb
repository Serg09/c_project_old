module CampaignsHelper
  def campaign_row_class(campaign)
    if campaign.collected?
      'success'
    elsif campaign.cancelled?
      'danger'
    elsif campaign.cancelling? || campaign.collecting?
      'warning'
    end
  end
end
