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

  def start_campaign_path(campaign)
    if campaign.author_ready?
      terms_campaign_path(campaign)
    else
      '#'
    end
  end

  def start_campaign_title(campaign)
    if campaign.author_ready?
      'Click here to start the campaign.'
    else
      'You must have an approved bio before you can start the campaign.'
    end
  end

  def start_campaign_button_class(campaign)
    if campaign.author_ready?
      'btn-success'
    else
      'btn-default'
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
