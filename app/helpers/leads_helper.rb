module LeadsHelper
  # TODO: do we care about the case where text is empty?
  def lead_tag(lead)
    return nil if lead.nil? or lead.text.nil?
    # TODO: this is for a root, is that good enough?
    lead.text.slice(0..25) + (lead.text.size > 25 ? '...' : '')
  end

  def lead_link(lead)
    return nil if lead.nil?
    link_to(lead_tag(lead), lead)
  end
end
