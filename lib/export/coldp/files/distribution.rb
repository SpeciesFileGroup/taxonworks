# taxonID
# areaID
# area
# gazetteer
# status
# referenceID
# remarks
#
module Export::Coldp::Files::Distribution

  # TODO:
  #   Arbitrarily using MAX to grab one source is janky, but if CoL doesn't have
  #   extended model perhaps it doesn't matter.
  def self.asserted_distributions(otus)
    # TODO: Include Gaz ADs.
    AssertedDistribution.with(otu_scope: otus.unscope(:order).select(:id))
      .joins("JOIN otu_scope on otu_scope.id = asserted_distributions.asserted_distribution_object_id AND asserted_distributions.asserted_distribution_object_type = 'Otu'")
      .joins("JOIN geographic_areas on asserted_distributions.asserted_distribution_shape_id = geographic_areas.id AND asserted_distributions.asserted_distribution_shape_type = 'GeographicArea'")
      .joins(:sources)
      .where(is_absent: [false, nil])
      .select('asserted_distribution_shape_id, asserted_distribution_object_id, name, iso_3166_a3, iso_3166_a2, "tdwgID", data_origin, asserted_distributions.updated_at, asserted_distributions.updated_by_id,
              MAX(sources.cached) AS cached, MAX(sources.id) AS source_id')
      .group('asserted_distribution_shape_id, asserted_distribution_object_id, name, iso_3166_a3, iso_3166_a2, "tdwgID", data_origin, asserted_distributions.updated_at, asserted_distributions.updated_by_id' )
  end

  def self.content_distributions(otus, project_id: nil)
    # TODO: change to CVT URI
    cvt_name  = 'Distribution text'

    topic_id = ControlledVocabularyTerm.find_by(
      project_id:,
      name: cvt_name)

    return [] if topic_id.blank?

    Content.with(otu_scope: otus.unscope(:order).select(:id))
      .joins('JOIN otu_scope on otu_scope.id = contents.otu_id')
      .where(contents: {topic_id: })
      .select('otus.id, contents.text, contents.updated_at, contents.updated_by_id')
      .distinct
  end

  def self.generate(otus, project_members, reference_csv = nil, project_id: nil )
    CSV.generate(col_sep: "\t") do |csv|

      csv << %w{
        taxonID
        areaID
        area
        gazetteer
        status
        referenceID
        modified
        modifiedBy
        remarks
      }

      # We gather the scope (not data) so we can add references en-masse after
      ad_scope = add_asserted_distributions(otus, csv, project_members)
      cd_scope = add_content_distributions(otus, csv, project_members, project_id:)

      r1 = Source.with(d_scope: ad_scope)
        .joins('JOIN d_scope on d_scope.source_id = sources.id')
        .select('sources.id, sources.cached, sources.updated_at, sources.updated_by_id')
        .distinct

      r2 = Source.with(d_scope: cd_scope)
        .joins('JOIN d_scope on d_scope.source_id = sources.id')
        .select('sources.id, sources.cached, sources.updated_at, sources.updated_by_id')
        .distinct

      Export::Coldp::Files::Reference.add_reference_rows(r1.to_a, reference_csv, project_members) unless ad_scope.empty?
      Export::Coldp::Files::Reference.add_reference_rows(r2.to_a, reference_csv, project_members) unless cd_scope.empty?
    end
  end

  def self.add_asserted_distributions(otus, csv, project_members)
    ads = asserted_distributions(otus)

    ads.each do |ad|
      if !ad.iso_3166_a3.blank?
        gazetteer = 'iso'
        area_id = ad.iso_3166_a3
        area = ad.iso_3166_a3
      elsif !ad.iso_3166_a2.blank?
        gazetteer = 'iso'
        area_id = ad.iso_3166_a2
        area = ad.iso_3166_a2
      elsif !ad.tdwgID.blank?
        gazetteer = 'tdwg'
        if ad.data_origin == 'tdwg_l3' or ad.data_origin == 'tdwg_l4'
          area_id = ad.tdwgID.gsub(/^[0-9]{1,2}(.+)$/, '\1')  # fixes mismatch in TW vs CoL TDWG level 3 & 4 identifiers
        else
          area_id = ad.tdwgID
        end
        area = area_id
      else
        gazetteer = 'text'
        area_id = nil
        area = ad.name
      end

      csv << [
        ad.asserted_distribution_object_id,
        area_id,
        area,
        gazetteer,
        nil,
        ad.source_id,                                                  # reference_id - only 1 distribution reference allowed
        Export::Coldp.modified(ad.updated_at),                         # modified
        Export::Coldp.modified_by(ad.updated_by_id, project_members),  # modified_by
        nil
      ]
    end


    ads # return scope for reference handling
  end

  def self.add_content_distributions(otus, csv, project_members, project_id: )
    cd = content_distributions(otus, project_id: )
    cd.length # TODO: remove !?

    cd.each do |o|
      csv << [
        o.id,
        nil,
        o.text,
        'text',
        nil,
        nil,
        Export::Coldp.modified(o.updated_at),
        Export::Coldp.modified_by(o.updated_by_id, project_members),
        nil
      ]
    end
    cd # return scope for reference handling
  end
end
