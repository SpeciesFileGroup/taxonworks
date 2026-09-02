class InaturalistImportJob < ApplicationJob
  queue_as :inaturalist_import

  # @param results [Array<Hash>] pre-fetched Nasturtium observation results
  # @param project_id [Integer]
  # @param user_id [Integer]
  # @param match_otu_by_name [Boolean]
  # @param use_community_taxon [Boolean]
  # @param import_images [Boolean]
  # @param import_sounds [Boolean]
  def perform(results:, project_id:, user_id:, match_otu_by_name: false, use_community_taxon: true, import_images: false, import_sounds: false)
    Current.project_id = project_id
    Current.user_id = user_id

    # Reuse one Person across this run for an observer/copyright holder/etc.
    # that would otherwise be built repeatedly.
    @person_cache = {}

    results.each do |result|
      import_observation(result, project_id:, match_otu_by_name:, use_community_taxon:, import_images:, import_sounds:)
    end
  end

  private

  # The observation's observer as a saved Person, deduplicated across the run.
  def observer_person(result)
    person = ::Vendor::Nasturtium.stub_observer_person(result, person_cache: @person_cache)
    person.save! if person.new_record?
    person
  end

  def import_observation(result, project_id:, match_otu_by_name:, use_community_taxon:, import_images:, import_sounds:)
    ApplicationRecord.transaction do
      # Save the OTU first so otu.id is available for the TaxonDetermination nested
      # attributes — reject_taxon_determinations rejects entries with a blank otu_id
      # and a blank otu.id, which is the case for any new (unsaved) OTU object.
      otu = ::Vendor::Nasturtium.stub_otu(result, project_id:, match_by_name: match_otu_by_name, use_community_taxon:)
      unless otu
        Rails.logger.warn("InaturalistImportJob: skipping observation #{result['id']} — no taxon name")
        return
      end
      otu.save! if otu.new_record?

      # Save the CE (and its nested georeference) before the FO so that
      # collecting_event_id is set when the FO is created.
      ce = ::Vendor::Nasturtium.stub_collecting_event(result)
      ce.save!

      if (georef = ce.georeferences.first)
        georef.georeferencer_roles.create!(person: observer_person(result))
      end

      d = result['observed_on_details']
      fo = FieldOccurrence.new(
        total: 1,
        collecting_event: ce,
        taxon_determinations_attributes: [{
          otu_id: otu.id,
          year_made: d['year'],
          month_made: d['month'],
          day_made: d['day'],
        }],
        identifiers: [::Vendor::Nasturtium.stub_identifier(result)].compact,
      )
      fo.save!

      ::Vendor::Nasturtium.stub_biocuration_classes(result, project_id:).each do |biocuration_class|
        BiocurationClassification.create!(biocuration_class:, biocuration_classification_object: fo)
      end

      unless use_community_taxon
        td = fo.taxon_determinations.first
        td.determiner_roles.create!(person: observer_person(result))

        if (ident_uuid = ::Vendor::Nasturtium.observer_identification_uuid(result))
          Identifier::Global::Uuid::InaturalistIdentification.create!(
            identifier_object: td,
            identifier: ident_uuid
          )
        end
      end

      if result['description'].present?
        Note.create!(note_object: fo, text: result['description'])
      end

      import_photos(result, fo:) if import_images
      import_sounds(result, fo:) if import_sounds
    end
  rescue => e
    # Failures are logged but do not interrupt the remaining imports
    Rails.logger.error(
      "InaturalistImportJob: failed to import observation #{result['id']}: " \
      "#{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
    )
  end

  # For each CC/PD-licensed sound on the observation, create a Sound with full
  # licensing metadata and attach it as a Conveyance on the FO.
  def import_sounds(result, fo:)
    observed_year = result.dig('observed_on_details', 'year')

    ::Vendor::Nasturtium.permitted_sounds(result).each do |obs_sound|
      ApplicationRecord.transaction do
        sound = ::Vendor::Nasturtium.build_sound!(obs_sound, result:, observed_year:, person_cache: @person_cache)
        Conveyance.create!(sound:, conveyance_object: fo)
      end
    rescue => e
      Rails.logger.error(
        "InaturalistImportJob: failed to import sound #{obs_sound['uuid']} " \
        "for observation #{result['uuid']}: #{e.class}: #{e.message}\n" \
        "#{e.backtrace&.first(5)&.join("\n")}"
      )
    end
  end

  def import_photos(result, fo:)
    observed_year = result.dig('observed_on_details', 'year')

    ::Vendor::Nasturtium.permitted_photos(result).each do |obs_photo|
      ApplicationRecord.transaction do
        image = ::Vendor::Nasturtium.build_image!(obs_photo, result:, observed_year:, person_cache: @person_cache)
        Depiction.create!(image:, depiction_object: fo)
      end
    rescue => e
      Rails.logger.error(
        "InaturalistImportJob: failed to import photo #{obs_photo['uuid']} " \
        "for observation #{result['uuid']}: #{e.class}: #{e.message}\n" \
        "#{e.backtrace&.first(5)&.join("\n")}"
      )
    end
  end

end
