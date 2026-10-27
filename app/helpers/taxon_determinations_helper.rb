module TaxonDeterminationsHelper

  # @return [String, nil]
  #    a descriptor, contains name only (if you want to include the identifier use collection_object_tag)
  def taxon_determination_tag(taxon_determination)
    return nil if taxon_determination.nil?
    ['det.', determination_tag(taxon_determination) ].join(' ').html_safe
  end

  # @return [String]
  #   as for taxon_determination_tag but does not reference collection object
  def determination_tag(taxon_determination)
    return nil if taxon_determination.nil?
    [ otu_tag(taxon_determination.otu),
      taxon_determination_by(taxon_determination),
      taxon_determination_on(taxon_determination)
    ].compact.join(' ').html_safe
  end

  def label_for_taxon_determination(taxon_determination)
    [ label_for_otu(taxon_determination.otu),
      taxon_determination_by(taxon_determination),
      taxon_determination_on(taxon_determination)
    ].compact.join(' ')
  end

  # @return [String]
  #   as for taxon_determination_tag but does not reference collection object, links to OTU
  def taxon_determination_link(taxon_determination)
    link_to(determination_tag(taxon_determination), browse_otus_task_path(taxon_determination.otu))
  end

  # @return [String]
  #   the "by" clause of the determination
  def taxon_determination_by(taxon_determination)
    # Preloaded roles when there are any (as by filter tables), else two queries.
    people, organizations =
      if taxon_determination.determiner_roles.loaded?
        roles = taxon_determination.determiner_roles
        [roles.filter_map(&:person), roles.filter_map(&:organization)]
      else
        [taxon_determination.determiners, taxon_determination.determiners_organization]
      end

    names = [
      people.collect{|d| d.last_name },
      organizations.collect{|d| d.name }
    ].reduce([], :concat).to_sentence

    names.blank? ? nil : "by #{names}"
  end

  # @return [String]
  #   the date clause of the determination
  def taxon_determination_on(taxon_determination)
    !taxon_determination.date.blank? ? "on #{taxon_determination.date}" : nil
  end

end
