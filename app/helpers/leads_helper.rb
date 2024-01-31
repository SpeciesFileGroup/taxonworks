module LeadsHelper
  def lead_tag(lead)
    return nil if lead.nil?
    lead.description.slice(0..25) + (lead.description.size > 25 ? '...' : '')
  end

  def lead_link(lead)
    return nil if lead.nil?
    link_to(lead_tag(lead), lead)
  end
end
