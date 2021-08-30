# Concept is a chronological history of the collection object
require 'catalog'
class Catalog::CollectionObject < ::Catalog

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
    :became_origin_of,
    :originated_from
  ].freeze

  # Group the events so that they can be toggled
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
    became_origin_of: :lab,
    originated_from: :lab,
  }.freeze

  # rubocop:disable Metrics/MethodLength
  # @param [CollectionObject] collection_object
  # @return [Catalog::CollectionObject::Entry]
  def self.data_for(collection_object)
    o = collection_object
    data = Catalog::CollectionObject::Entry.new(o)

    data.items << Catalog::CollectionObject::EntryItem.new(type: :collected_on, object: o.collecting_event, start_date: o.collecting_event.start_date, end_date: o.collecting_event.end_date) if o.collecting_event_id.present?

    data.items << Catalog::CollectionObject::EntryItem.new(type: :digital_record_created_by, object: o.creator, start_date: o.created_at.to_time)
    data.items << Catalog::CollectionObject::EntryItem.new(type: :digital_record_updated_by, object: o.updater, start_date: o.updated_at.to_time)

    o.origin_relationships.each do |a|
      data.items << Catalog::CollectionObject::EntryItem.new(
        type: :became_origin_of,
        object: a,
        start_date: a.created_at )
    end

    o.related_origin_relationships.each do |a|
      data.items << Catalog::CollectionObject::EntryItem.new(
        type: :originated_from,
        object: a,
        start_date: a.created_at )
    end

    o.all_biological_associations.each do |a|
      data.items << Catalog::CollectionObject::EntryItem.new(
        type: :biologically_associated,
        object: a,
        start_date: a.created_at )
    end

    o.biocuration_classifications.each do |b|
      data.items << Catalog::CollectionObject::EntryItem.new(
        type: :biologically_classified,
        object: b,
        start_date: b.created_at.to_time)
    end

    o.versions.each do |v|
      data.items << Catalog::CollectionObject::EntryItem.new(
        type: :updated_metadata,
        object: v,
        start_date: v.created_at.to_time)
    end

    o.georeferences.each do |g|
      data.items << Catalog::CollectionObject::EntryItem.new(
        type: :georeferenced,
        object: g,
        start_date: g.created_at.to_time)
    end

    o.type_designations.each do |t|
      date = t&.source&.nomenclature_date
      data.items << Catalog::CollectionObject::EntryItem.new(type: :typified, object: t, start_date: date)
    end

    o.taxon_determinations.each do |td|
      data.items << Catalog::CollectionObject::EntryItem.new(type: :determined, object: td, start_date: td.sort_date)
    end

    o.identifiers.each do |i|
      data.items << Catalog::CollectionObject::EntryItem.new(
        type: :given_identifier,
        object: i,
        start_date: i.created_at)
    end

    o.loan_items.each do |li|
      data.items << Catalog::CollectionObject::EntryItem.new(
        type: :sent_for_loan,
        object: li.loan,
        start_date: li.loan.date_sent.to_time
      ) if li.loan.date_sent

      data.items << Catalog::CollectionObject::EntryItem.new(
        type: :returned_from_loan,
        object: li.loan,
        start_date: (li.returned? ? li.date_returned.to_time : li.loan.date_closed.to_time)
      ) if li.loan.date_closed || li.returned?
    end

    o.tags.each do |t|
      data.items << Catalog::CollectionObject::EntryItem.new(
        type: :tagged, object: t, start_date: t.created_at.to_time)
    end

    o.data_attributes.each do |d|
      data.items << Catalog::CollectionObject::EntryItem.new(
        type: :added_attribute,
        object: d,
        start_date: d.created_at.to_time)
    end

    o.notes.each do |n|
      data.items << Catalog::CollectionObject::EntryItem.new(
        type: :added_note,
        object: n,
        start_date: n.created_at.to_time)
    end

    o.depictions.each do |d|
      t = d.is_metadata_depiction ? :metadata_depicted : :imaged

      data.items << Catalog::CollectionObject::EntryItem.new(
        type: t,
        object: d,
        start_date: d.created_at.to_time)
    end

    o.collecting_event && o.collecting_event.depictions.each do |d|
      t = d.is_metadata_depiction ? :collecting_event_metadata_depicted : :collection_site_imaged

      data.items << Catalog::CollectionObject::EntryItem.new(
        type: t,
        object: d,
        start_date: d.created_at.to_time)
    end

    data.items << Catalog::CollectionObject::EntryItem.new(
      type: :containerized,
      object: o.container,
      start_date: o.created_at.to_time)  if o.container


      # TODO: extracts, sequences,

      data
  end
  # rubocop:enable Metrics/MethodLength

end
