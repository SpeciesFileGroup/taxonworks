module Tasks::Gis::OtuDistributionDataHelper

  def otu_aggregation(otu)
    retval                      = otu.distribution_geoJSON
    retval['properties']['tag'] = object_tag(otu)
    retval
  end

  def without_shape?(distributions)
    count = 0
    distributions.each { |dist|
      count += 1 if dist.geographic_area.geographic_items.count == 0
    }
    ", #{count} without shape" if count > 0
  end

  def distribution_previous_next(object, type, distribution = nil)
    case type
    when 'Otu'
      content_tag(:span, (previous_otu_distribution_link(object, distribution) + ' | ' + next_otu_distribution_link(object, distribution)).html_safe)
    when 'Taxon name'
      content_tag(:span, (previous_taxon_name_distribution_link(object) + ' | ' + next_taxon_name_distribution_link(object)).html_safe)
    end
    
  end

  def next_taxon_name_distribution_link(taxon_name)
    if id =  TaxonName.where("id > #{taxon_name.id}").with_project_id(sessions_current_project_id).order(id: :asc).limit(1).pluck(:id).first
      link_to 'Next', taxon_name_distribution_data_task_url(id)
    else
      'Next'
    end
  end

  def previous_taxon_name_distribution_link(taxon_name)
    if id = TaxonName.where("id < #{taxon_name.id}").with_project_id(sessions_current_project_id).order(id: :desc).limit(1).pluck(:id).first
      link_to 'Previous', taxon_name_distribution_data_task_url(id) 
    else
      'Previous'
    end 
  end

  def next_otu_distribution_link(otu, distribution)
    if id = Otu.where("id > #{distribution.otus.first.id}").with_project_id(sessions_current_project_id).order(id: :asc).limit(1).pluck(:id).first 
      link_to 'Next', otu_distribution_data_task_url(id)
    else
      'Next'
    end 
  end

  def previous_otu_distribution_link(otu, distribution)
    if id = Otu.where("id < #{distribution.otus.first.id}").with_project_id(sessions_current_project_id).order(id: :desc).limit(1).pluck(:id).first
    link_to 'Previous', otu_distribution_data_task_url(id)
    else
      'Previous'
    end
  end

end
