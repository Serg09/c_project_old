module ApplicationHelper
  FLASH_MAP = {
    'notice' => 'success',
    'alert' => 'danger'
  }

  def author_nav_item_caption
    pending_count = Author.pending.count
    return 'Authors' if pending_count == 0
    "Authors <span class=\"badge\">#{pending_count}</span>".html_safe
  end

  def flash_key_to_alert_class(flash_key)
    "alert-#{FLASH_MAP[flash_key] || flash_key}"
  end

  def flash_test?
    if params[:flash_test].present?
      flash[:notice] = "This is a notice"
      flash[:alert] = "This is an alert"
      flash[:info] = "This is some info"
      flash[:warning] = "This is a warning"
      true
    end
    false
  end

  def format_date_time(datetime)
    datetime.strftime '%-m/%-d/%Y %I:%M %p'
  end

  def form_group_class(model, attribute)
    model.errors[attribute].any? ? 'has-error' : nil
  end

  def help_blocks(model, attribute)
    messages = model.errors.full_messages_for(attribute)
    return nil unless messages.any?
    messages.map do |m|
      content_tag :span, m, class: 'help-block'
    end.join('').html_safe
  end
end
