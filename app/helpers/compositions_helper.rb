module CompositionsHelper

  # Community and project Compositions may share type, name and version, so
  # community is always marked.
  def composition_tag(composition)
    return nil if composition.nil?
    s = [composition.type, ERB::Util.html_escape(composition.name)]
    s.push("v#{composition.version}") if composition.version
    s.push(content_tag(:span, '[community]', class: :subtle)) if composition.is_community?
    s.join(' ')
  end

  def label_for_composition(composition)
    return nil if composition.nil?
    s = [composition.type, composition.name]
    s.push("v#{composition.version}") if composition.version
    s.push('[community]') if composition.is_community?
    s.join(' ')
  end

  def composition_link(composition)
    return nil if composition.nil?
    link_to(composition_tag(composition).html_safe, composition.metamorphosize)
  end

  def compositions_search_form
    render('/compositions/quick_search_form')
  end

  def composition_autocomplete_selected_tag(composition)
    return nil if composition.nil?
    label_for_composition(composition)
  end

end
