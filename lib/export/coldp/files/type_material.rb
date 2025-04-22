# ID
# nameID
# citation
# status
# referenceID
# locality
# country
# latitude
# longitude
# altitude
# host
# date
# collector
# institutionCode
# catalogNumber
# associatedSequences
# sex
# link
# remarks
#
module Export::Coldp::Files::TypeMaterial

  def self.locality(co)
    [co.dwc_country, co.dwc_state_province, co.dwc_county, co.dwc_locality].compact.join(', ')
  end

  def self.date(co)
    co.dwc_event_date&.split('/')[0] unless co.dwc_event_date.nil?
  end

  # We need to catch types for valid and invalid names.
  def self.type_material(otu)
    a = ::Export::Coldp::Files::Name.core_names(otu).unscope(:select).select(:id)
    b = ::Export::Coldp::Files::Name.invalid_core_names(otu).unscope(:select).select(:id)
    c = ::Queries.union(TaxonName, [a,b]).select(:id)

    TypeMaterial.with(name_scope: c)
      .joins(collection_object: [:dwc_occurrence])
      .joins('JOIN name_scope on name_scope.id = type_materials.protonym_id')
      .left_joins(:source) # original only, not subsequent here, probably people are using Protonym as a proxy
      .select('type_materials.*, MAX(sources.id) source_id, country, locality, "decimalLatitude", "decimalLongitude", "verbatimElevation", "eventDate", "recordedBy", "institutionCode", "catalogNumber", sex')
      .group('type_materials.id , country, locality, "decimalLatitude", "decimalLongitude", "verbatimElevation", "eventDate", "recordedBy", "institutionCode", "catalogNumber", sex')
  end

  def self.generate(otu, project_members, reference_csv = nil )

    tm = nil

    text = ::CSV.generate(col_sep: "\t") do |csv|

      csv << %w{
        ID
        nameID
        citation
        status
        referenceID
        locality
        country
        latitude
        longitude
        altitude
        host
        date
        collector
        institutionCode
        catalogNumber
        associatedSequences
        sex
        link
        modified
        modifiedBy
        remarks
      }

      tm = type_material(otu)

      tm.each do |r|
        text = csv << [
          nil,                                                            # ID: don't expose TW internal type material ID
          r.protonym_id,                                                  # nameID
          nil,                                                            # citation ?! co.buffered_collecting_event
          r.type_type,                                                    # status
          r.source_id,                                                    # referenceID
          r.locality,                                                     # locality
          r.country,                                                      # country
          r.decimalLatitude,                                              # latitude
          r.decimalLongitude,                                             # longitude
          r.verbatimElevation,                                            # altitude
          nil,                                                            # host
          r.eventDate,                                                    # date
          r.recordedBy,                                                   # collector
          r.institutionCode,                                              # institutionCode
          r.catalogNumber,                                                # catalogNumber
          nil,                                                            # associatedSequences: unclear what is wanted? https://github.com/CatalogueOfLife/coldp#associatedsequences
          r.sex,                                                          # sex
          nil,                                                            # link # maybe to GBIF by occurrenceID
          Export::Coldp.modified(r.updated_at),                           # modified
          Export::Coldp.modified_by(r.updated_by_id, project_members),    # modifiedBy
          nil                                                             # remarks
        ]
      end
    end

    # TODO: Many people likely don't cite TypeMaterial directly, but rather the Protonym, we could
    # use that proxy.
    sources = Source.with(name_scope: tm)
      .joins(:citations)
      .joins("JOIN name_scope ns on ns.id = citations.citation_object_id AND citations.citation_object_type = 'TypeMaterial'")
      .distinct

    Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv, project_members) if reference_csv

    text
  end
end
