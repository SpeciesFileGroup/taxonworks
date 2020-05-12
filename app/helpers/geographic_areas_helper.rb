module GeographicAreasHelper

  def geographic_area_tag(geographic_area)
    return nil if geographic_area.nil?
    geographic_area.name
  end

  def geographic_area_autocomplete_tag(geographic_area, term)
    return nil if geographic_area.nil?

    if term
      s = geographic_area.name.gsub(/#{Regexp.escape(term)}/i, "<mark>#{term}</mark>") + ' ' # weee bit simpler
    else
      s = geographic_area.name + ' '
    end
    s = [geographic_area&.parent&.parent&.name, geographic_area&.parent&.name, s].compact.join(': ').gsub('Earth: ', '')

#    s += " (#{geographic_area.parent.name}) " unless geographic_area.parent.nil?
    s += content_tag(:span, geographic_area.geographic_area_type.name, class: [:feedback, 'feedback-info', 'feedback-thin'])  unless geographic_area.geographic_area_type.nil?
    s += ' ' + (geographic_area.has_shape? ? content_tag(:span, 'has shape', class: [:feedback, 'feedback-success', 'feedback-thin']) : content_tag(:span, 'without shape', class: [:feedback, 'feedback-danger', 'feedback-thin']) )

    c = geographic_area.collecting_events.where(project_id: sessions_current_project_id).count + geographic_area.asserted_distributions.where(project_id: sessions_current_project_id).count 

    s += ' ' + ( c > 0 ? content_tag(:span, "#{c.to_s}&nbsp;#{'use'.pluralize(c)}".html_safe, class: [:feedback, 'feedback-secondary', 'feedback-thin']) : '' )
    
    s.html_safe
  end

  def geographic_area_link(geographic_area, link_text = nil)
    return nil if geographic_area.nil?
    link_text ||= geographic_area.name
    link_to(link_text, geographic_area)
  end

  def geographic_areas_search_form
    render('/geographic_areas/quick_search_form')
  end

  def geographic_areas_link_list_tag(geographic_areas)
    geographic_areas.collect { |ga| link_to(ga.name, ga) }.join(',')
  end

  def geographic_area_link_list(geographic_areas)
    content_tag(:ul) do
      geographic_areas.collect { |a| content_tag(:li, geographic_area_link(a)) }.join.html_safe
    end
  end

  def geographic_area_data_origin_select_tag
    select_tag(:data_origin, options_for_select(GeographicArea.pluck(:data_origin).uniq), include_blank: true)
  end

end
