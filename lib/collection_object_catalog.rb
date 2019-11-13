# Concept is a chronological history of the collection object
module CollectionObjectCatalog

  # An arbitrary vocabulary of human-readable event names (tags)
  # in the lifetime of a collection object
  EVENT_TYPES = [
    :born,
    :died,
    :collected_on,
    :determined,
    :described,
    :given_identifier,
    :georeferenced,
    :destroyed,
    :placed_in_repository,
    :sent_for_loan,
    :returned_from_loan,
    :updated_metadata,
    :added_note,
    :annotated,
    :cited,
    :containerized,
    :extracted_from,
    :sequenced,
    :dissected,
    :tagged,
    :typified,
    :added_attribute,
    :biologically_classified,
    :fossilized_between, # chronological time period b/w which specimen was fossilized
    :imaged, # == depicted
    :metadata_depicted,
    :collecting_event_metadata_depicted,
    :collection_site_imaged,
    :digital_record_created_by,
    :digital_record_updated_by,
    :biologically_associated,
  ].freeze

  FILTER_MAP = {
    born: :life,
    died: :life, 
    collected_on: :collecting_event, 
    determined: :taxon_determinations,
    described: :observations,
    given_identifier: :annotations,
    georeferenced: :collecting_event, 
    destroyed: :accessions,
    placed_in_repository: :accessions, 
    sent_for_loan: :loans, 
    returned_from_loan: :loans,
    updated_metadata: :annotations, 
    added_note: :annotations, 
    annotated: :annotations,
    cited: :annotations, 
    containerized: :accessions,
    extracted_from: :lab,
    sequenced: :lab,
    dissected: :lab,
    tagged: :annotations,
    typified: nil, 
    added_attribute: :annotations, 
    biologically_classified: :biology,
    fossilized_between:  :collecting_event, 
    imaged: :images, 
    metadata_depicted: :images, 
    collecting_event_metadata_depicted: :images,
    collection_site_imaged: :collecting_event,  
    biologically_associated: :biology,
  }.freeze

  # rubocop:disable Metrics/MethodLength
  # @param [CollectionObject] collection_object
  # @return [CollectionObjectCatalog::CatalogEntry]
  def self.data_for(collection_object)
    o = collection_object
    data = CollectionObjectCatalog::CatalogEntry.new(o)

    data.items << CollectionObjectCatalog::EntryItem.new(type: :collected_on, object: o.collecting_event, start_date: o.collecting_event.start_date, end_date: o.collecting_event.end_date) if o.collecting_event_id.present?

    data.items << CollectionObjectCatalog::EntryItem.new(type: :digital_record_created_by, object: o.creator, start_date: o.created_at.to_time)
    data.items << CollectionObjectCatalog::EntryItem.new(type: :digital_record_updated_by, object: o.updater, start_date: o.updated_at.to_time)

    o.all_biological_associations.each do |a|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :biologically_associated,
                                                           object: a,
                                                           start_date: a.created_at )
    end

    o.biocuration_classifications.each do |b|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :biologically_classified,
                                                           object: b,
                                                           start_date: b.created_at.to_time)
    end

    o.versions.each do |v|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :updated_metadata,
                                                           object: v,
                                                           start_date: v.created_at.to_time)
    end

    o.georeferences.each do |g|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :georeferenced,
                                                           object: g,
                                                           start_date: g.created_at.to_time)
    end

    o.type_designations.each do |t|
      date = t&.source&.nomenclature_date
      data.items << CollectionObjectCatalog::EntryItem.new(type: :typified, object: t, start_date: date)
    end

    o.taxon_determinations.each do |td|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :determined, object: td, start_date: td.sort_date)
    end

    o.identifiers.each do |i|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :given_identifier,
                                                           object: i,
                                                           start_date: i.created_at)
    end

    o.loan_items.each do |li|
      data.items << CollectionObjectCatalog::EntryItem.new(
        type: :sent_for_loan,
        object: li.loan,
        start_date: li.loan.date_sent.to_time
      ) if li.loan.date_sent

      data.items << CollectionObjectCatalog::EntryItem.new(
        type: :returned_from_loan,
        object: li.loan,
        start_date: (li.returned? ? li.date_returned.to_time : li.loan.date_closed.to_time)
      ) if li.loan.date_closed || li.returned?
    end

    o.tags.each do |t|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :tagged, object: t, start_date: t.created_at.to_time)
    end

    o.data_attributes.each do |d|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :added_attribute,
                                                           object: d,
                                                           start_date: d.created_at.to_time)
    end

    o.notes.each do |n|
      data.items << CollectionObjectCatalog::EntryItem.new(type: :added_note,
                                                           object: n,
                                                           start_date: n.created_at.to_time)
    end

    o.depictions.each do |d|
      t = d.is_metadata_depiction ? :metadata_depicted : :imaged

      data.items << CollectionObjectCatalog::EntryItem.new(type: t,
                                                           object: d,
                                                           start_date: d.created_at.to_time)
    end

    o.collecting_event && o.collecting_event.depictions.each do |d|
      t = d.is_metadata_depiction ? :collecting_event_metadata_depicted : :collection_site_imaged

      data.items << CollectionObjectCatalog::EntryItem.new(type: t,
                                                           object: d,
                                                           start_date: d.created_at.to_time)
    end

    data.items << CollectionObjectCatalog::EntryItem.new(type: :containerized,
                                                         object: o.container,
                                                         start_date: o.created_at.to_time)  if o.container

    # in eyelet
    # extracts, sequences,

    data
  end
  # rubocop:enable Metrics/MethodLength

end

