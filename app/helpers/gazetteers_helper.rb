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

  def gazetteer_link_list(gazetteers)
    content_tag(:ul) do
      gazetteers.collect { |a| content_tag(:li, gazetteer_link(a)) }.join.html_safe
    end
  end

  def gazetteer_autocomplete_tag(gazetteer)
    gazetteer_tag(gazetteer)
  end

  def gazetteers_search_form
    render('/gazetteers/quick_search_form')
  end


end
