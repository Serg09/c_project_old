module Admin::CampaignsHelper
  def contribution_row_class(contribution)
    return 'danger' if contribution.cancelled?
    return 'success' if contribution.collected?
  end
end
