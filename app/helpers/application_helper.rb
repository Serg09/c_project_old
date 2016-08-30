module ApplicationHelper
  FLASH_MAP = {
    'notice' => 'success',
    'alert' => 'danger'
  }

  def approve_path(resource)
    "approve_admin_#{resource.class.name.underscore}_path"
  end

  def reject_path(resource)
    "reject_admin_#{resource.class.name.underscore}_path"
  end

  def render_status_nav(statuses, &path_helper)
    current_status = params[:status] || statuses.first.downcase
    content_tag(:ul, class: 'nav nav-tabs') do
      statuses.map do |status|
        css = (status.downcase == current_status) ? 'active' : ''
        content_tag(:li, role: 'presentation', class: css) do
          link_to status, path_helper.call(status: status.downcase)
        end
      end.join('').html_safe
    end
  end

  def bio_nav_item_caption
    nav_item_caption 'Bios', Bio.pending.count
  end

  def book_nav_item_caption
    nav_item_caption 'Books', BookVersion.pending.count
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

  def format_date(date)
    date.strftime '%-m/%-d/%Y'
  end

  def format_date_time(datetime)
    datetime.strftime '%-m/%-d/%Y %l:%M %p'
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

  def inquiry_nav_item_caption
    pending_count = Inquiry.active.count
    return 'Inquiries' if pending_count == 0
    "Inquiries <span class=\"badge\">#{pending_count}</span>".html_safe
  end

  def parse_query(query)
    return {} unless query
    query.split('&')
      .map { |equation| equation.split('=') }
      .reduce({}) do |h, a|
        h[a[0].to_sym] = a[1]
        h
      end
  end

  def html_true?(value)
    %w(1 true).include? (value || '').downcase
  end

  def request_query
    @request_query ||= parse_query(request_uri.query)
  end

  def request_uri
    @request_uri ||= URI.parse(request.original_url)
  end

  def html_true(value)
    value.present? && %w(1 true).include?(value)
  end

  private

  def matches_path?(path_root, query, defaults)
    return false unless request_uri.path.starts_with? path_root
    query.all?{|k,v| (request_query[k] || defaults[k]) == v}
  end

  def nav_item_caption(caption, pending_count)
    return caption if pending_count == 0
    "#{caption} <span class=\"badge\">#{pending_count}</span>".html_safe
  end
end
