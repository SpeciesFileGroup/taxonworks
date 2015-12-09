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

  def forward_back_taxon_name_distribution(taxon_name)
    content_tag(:span, (previous_taxon_name_distribution(taxon_name) + ' | ' + next_taxon_name_distribution(taxon_name)).html_safe)
  end

  def previous_taxon_name_distribution(taxon_name)
    # next_link(taxon_name)
    # new_taxon_name_id = TaxonName.order(id: :desc).with_project_id(taxon_name.project_id).where('id < ?', taxon_name.id).limit(1).pluck(:id).first
    # link_to('previous', "#{new_taxon_name_id}")
    text        = 'Previous'
    # if taxon_name.respond_to?(:project_id)
    link_object = taxon_name.class.base_class.order(id: :desc).with_project_id(taxon_name.project_id).where(['id < ?', taxon_name.id]).limit(1).pluck(:id).first
    # else
    #   link_object = taxon_name.class.base_class.order(id: :desc).where(['id < ?', taxon_name.id]).limit(1).first
    # end
    # fail
    link_object.nil? ? text : link_to(text, "#{link_object}")
  end

  def next_taxon_name_distribution(taxon_name)
    # next_link(taxon_name)
    # new_taxon_name = TaxonName.order(id: :asc).with_project_id(taxon_name.project_id).where('id > ?', taxon_name.id).limit(1).first
    # link_to('next', "#{new_taxon_name_id}")
    text        = 'Next'
    # if taxon_name.respond_to?(:project_id)
    link_object = taxon_name.class.base_class.order(id: :asc).with_project_id(taxon_name.project_id).where(['id > ?', taxon_name.id]).limit(1).pluck(:id).first
    # else
    #   link_object = taxon_name.class.base_class.order(id: :asc).where(['id > ?', taxon_name.id]).limit(1).first
    # end
    link_object.nil? ? text : link_to(text, "#{link_object}")
  end
end
