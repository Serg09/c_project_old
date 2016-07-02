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

  DEFAULT_PROGRESS_METER_OPTIONS = { width: 100, height: 300 }
  def render_progress_meter(progress, options = {})
    options = DEFAULT_PROGRESS_METER_OPTIONS.
      merge(options || {}).
      merge(progress: progress)
    render 'shared/progress_meter', options
  end
end
