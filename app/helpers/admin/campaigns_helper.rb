module Admin::CampaignsHelper
  def donation_row_class(donation)
    return 'danger' if donation.cancelled?
    return 'success' if donation.collected?
  end
end
