module InquiriesHelper
  def email_link(inquiry)
    link_to inquiry.email, "mailto:#{inquiry.email}?subject=Crowdscribe+inquiery+#{('%06d' % inquiry.id)}"
  end
end
