# taxon_id
# name - ORIGINAL LANGUAGE
# transliteration
# language
# country
# area
# sex
# reference_id
# modified
# modifiedBy
#
module Export::Coldp::Files::VernacularName

  # @return [String, nil]
  #   the 'English' translation(s) if available
  def self.transliteration(common_name)
    n = common_name.alternate_values.where(type: 'AlternateValue::Translation', alternate_value_object_attribute: :name).load
    if n.any?
      n.collect{|a| a.language.name == 'English' ? a.value : nil}.compact.join('; ')
    else
      nil
    end
  end

  def self.area(common_name)
    common_name.geographic_area&.self_and_ancestors&.collect{|a| a.name}&.join('; ')
  end

  def self.common_names(otus)
    a = CommonName.with(otu_scope: otus.select(:id))
      .joins('JOIN otu_scope on otu_scope.id = common_names.otu_id')
      .left_joins(:geographic_area, :language, :sources)
      .select("common_names.*, geographic_areas.iso_3166_a2, languages.alpha_3_bibliographic, STRING_AGG(sources.id::text, ',') AS aggregate_source_ids")
      .group('common_names.id, geographic_areas.iso_3166_a2, languages.alpha_3_bibliographic')
  end

  def self.generate(otus, project_members, reference_csv = nil )
    cn = nil

    text = ::CSV.generate(col_sep: "\t") do |csv|
      csv << %w{
        taxonID
        name
        transliteration
        language
        country
        area
        referenceID
        modified
        modifiedBy
      }

      cn = common_names(otus)

      transliterations = AlternateValue::Translation.with(name_scope: cn)
        .joins("JOIN name_scope on alternate_values.alternate_value_object_id = name_scope.id AND alternate_values.alternate_value_object_type = 'CommonName'")
        .left_joins(:language)
        .where(languages: {english_name: 'English'}, alternate_value_object_attribute: 'name')
        .group('name_scope.id')
        .select("name_scope.id, STRING_AGG(alternate_values.value::text, ',') AS transliterations")
        .map{|a| [a.id, a.transliterations]}.to_h

      cn.each do |n|
        csv << [
          n.otu_id,                                                      # taxon_id
          n.name,                                                        # name
          transliterations[n.id],                                        # transliteration  # TODO: query expensive
          n.alpha_3_bibliographic,                                       # language
          n.iso_3166_a2,                                                 # country
          area(n),                                                       # area # TODO: query expensive
          n.aggregate_source_ids,                                        # reference_id
          Export::Coldp.modified(n[:updated_at]),                        # modified
          Export::Coldp.modified_by(n[:updated_by_id], project_members)  # modified_by
        ]
      end
    end

    sources = Source.with(name_scope: cn)
      .joins(:citations)
      .joins("JOIN name_scope ns on ns.id = citations.citation_object_id AND citations.citation_object_type = 'CommonName'")
      .distinct

    Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv, project_members) if reference_csv && sources.any?
    text
  end
end
