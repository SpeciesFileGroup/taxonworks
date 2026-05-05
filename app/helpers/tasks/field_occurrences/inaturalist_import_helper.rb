module Tasks::FieldOccurrences::InaturalistImportHelper

  def inaturalist_find_summary(results, existing_fo_by_uuid, fo_data:, use_community_taxon: true)
    results.map do |r|
      uuid = r['uuid']
      existing_fo_id = existing_fo_by_uuid[uuid]
      fo = fo_data[existing_fo_id]
      {
        observation_id: r['id'].to_s,
        uuid:,
        taxon_name: fo&.dig(:taxon_name) || ::Vendor::Nasturtium.taxon_name(r, use_community_taxon:),
        observer: r.dig('user', 'name').presence || r.dig('user', 'login'),
        observed_on: r['observed_on'],
        place_guess: r['place_guess'],
        status: existing_fo_id ? 'found' : 'not_imported',
        field_occurrence_id: existing_fo_id,
        browse_url: existing_fo_id ? browse_field_occurrence_task_path(field_occurrence_id: existing_fo_id) : nil,
        image_count: fo ? fo.dig(:image_count) : ::Vendor::Nasturtium.permitted_photos(r).size,
        sound_count: fo ? fo.dig(:sound_count) : ::Vendor::Nasturtium.permitted_sounds(r).size
      }
    end
  end

  def inaturalist_import_summary(results, existing_fo_by_uuid, use_community_taxon:, import_images:, import_sounds:)
    results.map do |r|
      uuid = r['uuid']
      existing_fo_id = existing_fo_by_uuid[uuid]
      taxon_name = ::Vendor::Nasturtium.taxon_name(r, use_community_taxon:)
      status = if existing_fo_id
        'already_imported'
      elsif taxon_name.blank?
        'no_taxon'
      else
        'queued'
      end
      {
        observation_id: r['id'].to_s,
        uuid:,
        taxon_name:,
        observer: r.dig('user', 'name').presence || r.dig('user', 'login'),
        observed_on: r['observed_on'],
        place_guess: r['place_guess'],
        status:,
        field_occurrence_id: existing_fo_id,
        browse_url: existing_fo_id ? browse_field_occurrence_task_path(field_occurrence_id: existing_fo_id) : nil,
        image_count: import_images ? ::Vendor::Nasturtium.permitted_photos(r).size : nil,
        sound_count: import_sounds ? ::Vendor::Nasturtium.permitted_sounds(r).size : nil
      }
    end
  end

  def serialize_inat_field_occurrence(fo)
    inat_identifier = fo.identifiers.find { |i| i.is_a?(Identifier::Global::Uuid::InaturalistObservation) }
    {
      id: fo.id,
      taxon_name: otu_tag(fo.taxon_determinations.first.otu),
      verbatim_locality: fo.collecting_event.verbatim_locality,
      created_at: fo.created_at.strftime('%Y-%m-%d %H:%M'),
      browse_url: browse_field_occurrence_task_path(field_occurrence_id: fo.id),
      inat_url: inat_identifier ? "https://www.inaturalist.org/observations/#{inat_identifier.identifier}" : nil,
      image_count: fo.depictions.size,
      sound_count: fo.conveyances.size
    }
  end

end
