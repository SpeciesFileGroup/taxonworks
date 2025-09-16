module AnatomicalPartsHelper
  def anatomical_part_tag(anatomical_part)
    return nil if anatomical_part.nil?

    anatomical_part.cached
  end

  def anatomical_part_autocomplete_tag(anatomical_part)
    anatomical_part_tag(anatomical_part)
  end

  def label_for_anatomical_part(anatomical_part)
    anatomical_part_tag(anatomical_part)
  end

  def anatomical_parts_search_form
    render('/anatomical_parts/quick_search_form')
  end
end
