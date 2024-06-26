module GazetteersHelper
  def gazetteer_tag(gazetteer)
    return nil if gazetteer.nil?
    gazetteer.name
  end

  def label_for_gazetteer(gazetteer)
    return nil if gazetteer.nil?
    gazetteer.name
  end

  def gazetteer_link(gazetteer, link_text = nil)
    return nil if gazetteer.nil?
    link_text ||= gazetteer.name
    link_to(link_text, gazetteer)
  end

  def geographic_item_link(geographic_item, link_text = nil)
    return nil if geographic_item.nil?
    link_text ||= geographic_item.to_param
    link_to(link_text, geographic_item_path(geographic_item), data: {turbolinks: false})
  end

  def gazetteer_link_list(gazetteers)
    content_tag(:ul) do
      gazetteers.collect { |a| content_tag(:li, gazetteer_link(a)) }.join.html_safe
    end
  end

end
