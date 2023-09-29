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

  def self.generate(otus, project_members, reference_csv = nil )
    CSV.generate(col_sep: "\t") do |csv|

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

      TypeMaterial.joins(:otus).where(otus: otus).eager_load(:collection_object).find_each do |tm|

        co = tm.collection_object
        sources = tm.sources.load
        reference_ids = sources.collect{|a| a.id}
        reference_id = reference_ids.first

        csv << [
          nil,                                                            # ID: don't expose TW internal type material ID
          tm.protonym_id,                                                 # nameID
          co.buffered_collecting_event,                                   # citation
          tm.type_type,                                                   # status
          reference_id,                                                   # referenceID
          locality(co),                                                   # locality
          co.collecting_event&.cached_level0_geographic_name,             # country
          co.dwc_decimal_latitude,                                        # latitude
          co.dwc_decimal_longitude,                                       # longitude
          co.dwc_verbatim_elevation,                                      # altitude
          nil,                                                            # host
          date(co),                                                       # date
          co.dwc_recorded_by,                                             # collector
          co.dwc_institution_code,                                        # institutionCode
          co.dwc_catalog_number,                                          # catalogNumber
          nil,                                                            # associatedSequences: unclear what is wanted? https://github.com/CatalogueOfLife/coldp#associatedsequences
          nil,                                                            # sex
          nil,                                                            # link
          Export::Coldp.modified(tm[:updated_at]),                        # modified
          Export::Coldp.modified_by(tm[:updated_by_id], project_members), # modifiedBy
          nil                                                             # remarks
        ]

          Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv, project_members) if reference_csv
      end
    end
  end
end