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
    [co.collecting_event&.cached_level0_geographic_name, co.collecting_event&.cached_level1_geographic_name, co.collecting_event&.cached_level2_geographic_name].compact.join(', ')
  end

  # TODO: This very likely includes more than just hosts (symbiotypes):
  #   could possibly be narrowed down by checking if the biological relationship type's inverted name includes the word host?
  #     we are specifying the relationship type in the string to make it clearer
  def self.host(co)
    if co.biological_associations == []
      return nil
    end
    hosts = []
    co.biological_associations.each do |ba|
      if ba.biological_association_object_type == 'Otu'
        o = Otu.find(ba.biological_association_object_id)
        if o.taxon_name_id.nil?
          object_name = o.name
        else
          tn = TaxonName.find(Otu.find(ba.biological_association_object_id).taxon_name_id)
          object_name = tn.cached
        end
        rel_type = BiologicalRelationship.find(ba.biological_relationship_id)
        if rel_type.inverted_name.include? 'host'
          hosts.append("#{rel_type.name} #{object_name}")
        end
      end
    end
    hosts.to_sentence
  end

  # CollectingEvent.verbatim_date seems to be in different formats (e.g., "6.VIII.2018", "14 August 1992")
  # so preferably take start_date_xxxx and format to ISO 8601
  def self.date(co)
    date = [co.collecting_event&.start_date_year, co.collecting_event&.start_date_month, co.collecting_event&.start_date_day].compact.join('-')
    if co.collecting_event&.start_date_year.nil? or date.nil?  # if year is nil, verbatim_date might be better?
      date = co.collecting_event&.verbatim_date
    end
    date
  end

  def self.collector(co)
    collectors = []
    if co.collecting_event.nil? or co.collecting_event.roles.nil?
      return nil
    end
    co.collecting_event.roles.each do |role|
      collectors.append(Person.find(role.person_id).cached)
    end
    collectors.to_sentence
  end

  # TODO: Should we want to return the current repository acronym if co.current_repository_id is set?
  #       Will the catalogue number still be the same even if a collection object was moved to another institution?
  def self.institution_code(co)
    if co.current_repository_id.nil?
      repository_id = co.repository_id
    else
      repository_id = co.current_repository_id
    end
    repository = Repository.find(repository_id) unless repository_id.nil?
    repository&.acronym
  end

  # TODO: is the CollectionObject.preferred_catalog_number the right method to use?
  #   some CollectionObject identifier types like Identifier::Global::Uuid::TaxonworksDwcOccurrence and
  #   Identifier::Unknown are not exported by the preferred_catalog_number method, but perhaps that's desirable.
  def self.catalog_number(co)
    co.preferred_catalog_number.identifier
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
            co.collecting_event&.verbatim_latitude,             # latitude
            co.collecting_event&.verbatim_longitude,            # longitude
            co.collecting_event&.verbatim_elevation,            # altitude
            host(co),                                           # host
            date(co),                                           # date
            collector(co),                                      # collector
            institution_code(co),                               # institutionCode
            catalog_number(co),                                 # catalogNumber
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
