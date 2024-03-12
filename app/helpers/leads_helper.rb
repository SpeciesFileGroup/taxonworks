module LeadsHelper
  def lead_id(lead)
    return nil if lead.nil?
    lead.origin_label ? "[#{lead.origin_label}]" : ''
  end

  def lead_no_text
    '(No text)'
  end

  def lead_truncated_text(lead)
    return nil if lead.nil?
    text = lead.text || lead_no_text
    text.slice(0..25) + (text.size > 25 ? '...' : '')
  end

  def lead_edges(lead)
    edges =
      (lead.parent_id ? '↑' : '') +
      (lead.children.size > 0 ? '↓' : '')
  end

  def lead_tag(lead)
    return nil if lead.nil?
    lead_edges(lead) + lead_id(lead) + ' ' + lead_truncated_text(lead)
  end

  def lead_link(lead)
    return nil if lead.nil?
    link_to(lead_tag(lead), lead)
  end

  def lead_autocomplete_tag(lead)
    lead_tag(lead)
  end

  def label_for_lead(lead)
    lead_tag(lead)
  end

  def leads_search_form
    render('/leads/quick_search_form')
  end
end
