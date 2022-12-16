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

  def self.host(o, co)
    unless co.biological_associations.any?
      return nil
    end
    hosts = []
    co.biological_associations.where(biological_association_object_type: 'Otu').each do |ba|
      if o.taxon_name_id.nil?
        object_name = o.name
      else
        tn = TaxonName.find(o.taxon_name_id)
        object_name = tn.cached
      end
      hosts.append("#{ba.biological_relationship.name} #{object_name}")
    end
    hosts.to_sentence
  end
  
  def self.date(co)
    co.dwc_event_date&.split('/')[0] unless co.dwc_event_date.nil?
  end

  def self.generate(otus, reference_csv = nil )
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
        remarks
      }

      otus.joins(:type_materials).distinct.each do |o|
        o.type_materials.each do |tm|

          co = CollectionObject.find(tm.collection_object_id) unless tm.collection_object_id.nil?
          sources = tm.sources.load
          reference_ids = sources.collect{|a| a.id}
          reference_id = reference_ids.first

          csv << [
            nil,                                                # ID: don't expose TW internal type material ID
            tm.protonym_id,                                     # nameID
            co.buffered_collecting_event,                       # citation
            tm.type_type,                                       # status
            reference_id,                                       # referenceID
            locality(co),                                       # locality
            co.collecting_event&.cached_level0_geographic_name, # country
            co.dwc_decimal_latitude,                            # latitude
            co.dwc_decimal_longitude,                           # longitude
            co.dwc_verbatim_elevation,                          # altitude
            host(o, co),                                        # host
            date(co),                                           # date
            co.dwc_recorded_by,                                 # collector
            co.dwc_institution_code,                            # institutionCode
            co.dwc_catalog_number,                              # catalogNumber
            nil,                                                # associatedSequences: unclear what is wanted? https://github.com/CatalogueOfLife/coldp#associatedsequences
            nil,                                                # sex
            nil,                                                # link
            nil                                                 # remarks
          ]

          Export::Coldp::Files::Reference.add_reference_rows(sources, reference_csv) if reference_csv
        end
      end
    end
  end
end
