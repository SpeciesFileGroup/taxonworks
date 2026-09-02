require 'open-uri'

module Vendor

  #  a = Nasturtium.observations(id: '99182856')

  # Possible Extensions
  #   - CE with a iNat global UUID
  #   - Bonus set GA for CE based on string matching
  #   - predict_otu
  #
  # A middle-layer wrapper between Nasturtium and TaxonWorks
  module Nasturtium

    # Maps iNaturalist photo license_code values to CREATIVE_COMMONS_LICENSES keys.
    # Derived from the inat_codes entries in CREATIVE_COMMONS_LICENSES.
    # iNat codes not in this map (e.g. nil, 'arr') are not importable.
    INAT_LICENSE_CODE_TO_TW_LICENSE = CREATIVE_COMMONS_LICENSES
      .each_with_object({}) { |(k, v), h| h[v[:inat_code]] = k if v[:inat_code] }
      .freeze

    # Seconds before a synchronous iNat API call is abandoned.
    INAT_API_TIMEOUT = 15

    # Fetch multiple observations in a single iNat API request.
    # IDs are joined as a comma-separated string because Faraday serializes
    # Ruby arrays as id[]=...&id[]=... which the iNat API does not accept.
    #
    # @param ids [Array<String>] iNat observation integer IDs
    # @return [Array<Hash>] Nasturtium result hashes (only found observations are returned)
    # @raise [Timeout::Error] if the iNat API does not respond within INAT_API_TIMEOUT seconds
    def self.by_observation_ids(ids)
      return [] if ids.blank?

      Timeout.timeout(INAT_API_TIMEOUT) do
        ::Nasturtium.observations(id: ids.join(','), per_page: ids.size)['results']
      end
    end

    def self.taxon_name(result, use_community_taxon: true)
      if use_community_taxon
        result.dig('community_taxon', 'name').presence || result.dig('taxon', 'name')
      else
        result.dig('taxon', 'name')
      end
    end

    def self.stub_collecting_event(result, guess_as_locality: true)
      return nil if result.blank?

      d = result['observed_on_details']

      p = {
        verbatim_collectors: result.dig('user', 'name').presence,
        verbatim_date: result['observed_on_string'].presence,
        start_date_day: d['day'],
        start_date_month: d['month'],
        start_date_year: d['year'],
      }

      if (t = result['time_observed_at']).present?
        parsed = Time.parse(t)
        p[:time_start_hour]   = parsed.hour
        p[:time_start_minute] = parsed.min
        p[:time_start_second] = parsed.sec if parsed.sec > 0
      else
        p[:time_start_hour] = d['hour'] unless d['hour'].nil?
      end

      p[:verbatim_locality] = result['place_guess'] if guess_as_locality

      ce = CollectingEvent.new(
        p.merge(
          georeferences: [stub_georeference(result)].compact,
        )
      )

      collector = stub_collector(result)
      ce.collector_roles.build(person: collector) if collector

      ce
    end

    # Attempt to find a Person in TW by ORCID. Returns nil if iNat provides no ORCID,
    # or if no matching Person exists.
    #
    # @param result [Hash] a Nasturtium result
    # @return [Person, nil]
    def self.stub_collector(result)
      person_by_orcid(result)
    end

    # Find or build the observer as a Person.
    # Strategy: ORCID match first, then Person::Unvetted from user.name or user.login.
    # Used as determiner on TaxonDetermination and georeferencer on Georeference.
    #
    # @param result [Hash] a Nasturtium result
    # @param person_cache [Hash, nil] per-import-run cache (see .dedupe_person)
    # @return [Person]
    def self.stub_observer_person(result, person_cache: nil)
      person = person_by_orcid(result) ||
        person_from_display_name(result.dig('user', 'name').presence || result.dig('user', 'login'))

      dedupe_person(person, person_cache, result)
    end

    # Reuse a single Person within one import run for an observer / copyright holder
    # that would otherwise be built repeatedly (e.g. the same person as both
    # georeferencer and copyright holder, or across multiple photos in the batch).
    # Deduplication across separate import runs is intentionally not attempted.
    #
    # @param person [Person] a matched (persisted) or freshly built (new) Person
    # @param cache [Hash, nil] the run cache; when nil no deduplication is done
    # @param result [Hash, nil] the Nasturtium result `person` was built directly from
    #   (i.e. `person` *is* that result's `user`), used for an exact cache key. Omit
    #   when `person` has no such structured identity at all — e.g. a third-party
    #   photo credit (see .stub_copyright_person) — falls back to name-based matching,
    #   the only option left in that case.
    # @return [Person]
    def self.dedupe_person(person, cache, result = nil)
      return person if cache.nil?

      key = person_identity_key(person, result)
      cached = cache[key]
      return cached if cached && (cached.new_record? || Person.exists?(cached.id))

      cache[key] = person
    end

    # @param person [Person]
    # @param result [Hash, nil] the Nasturtium result `person` was built directly from
    # @return [String] a within-run identity key
    def self.person_identity_key(person, result)
      return "id:#{person.id}" if person.persisted?

      user_id = result&.dig('user', 'id')
      return "inat_user:#{user_id}" if user_id.present?

      "name:#{[person.first_name, person.last_name].filter_map { |s| s&.strip&.downcase&.presence }.join(' ')}"
    end

    # Attempt to find a Person in TW by the observer's ORCID.
    # Returns nil if iNat provides no ORCID or no matching Person exists.
    #
    # @param result [Hash] a Nasturtium result
    # @return [Person, nil]
    def self.person_by_orcid(result)
      orcid = result.dig('user', 'orcid')
      return nil if orcid.blank?

      # iNat may return the bare ID (0000-0001-2345-6789) or a full URL; normalise to URL form
      orcid_url = orcid.start_with?('http') ? orcid : "https://orcid.org/#{orcid}"

      Person
        .joins(:identifiers)
        .where(identifiers: { type: 'Identifier::Global::Orcid', cached: orcid_url })
        .first
    end

    def self.stub_georeference(result)
      return nil if result.blank?

      # Skip georeference for obscured observations — iNat jitters coordinates
      # within a ~22km bounding box, exceeding TW's 10km error_radius maximum.
      return nil if result['obscured']

      # Skip if the reported accuracy itself exceeds TW's 10km error_radius limit.
      accuracy = result['positional_accuracy']
      return nil if accuracy.present? && accuracy > 10_000

      c = result.dig('geojson', 'coordinates')

      return nil if c.blank?

      Georeference::Inaturalist.new(
        error_radius: result['positional_accuracy'],
        geographic_item: GeographicItem.new(
          geography: Gis::FACTORY.parse_wkt("POINT(#{c.first} #{c.second})")
        )
      )
    end

    # Find the UUID of the observer's current identification on the observation.
    # Only the observer's own identifications are considered; community taxon has no UUID.
    #
    # @param result [Hash] a Nasturtium result
    # @return [String, nil] UUID string, or nil if not found
    def self.observer_identification_uuid(result)
      user_id = result.dig('user', 'id')
      return nil if user_id.blank?

      ident = (result['identifications'] || []).find do |i|
        i.dig('user', 'id') == user_id && i['current']
      end

      ident&.dig('uuid')
    end

    # @param result [Hash] a Nasturtium result
    # @return [Identifier::Global::Uuid::InaturalistObservation, nil]
    def self.stub_identifier(result)
      return nil if result.blank?

      uuid = result['uuid']
      return nil if uuid.blank?

      Identifier::Global::Uuid::InaturalistObservation.new(identifier: uuid)
    end

    # Find or build an OTU for the iNat taxon.
    #
    # @param result [Hash] a Nasturtium result
    # @param project_id [Integer]
    # @param match_by_name [Boolean]
    #   if true, look for an existing OTU with matching name in the project first
    # @param use_community_taxon [Boolean]
    #   if true, use the community consensus taxon (community_taxon, falling back to
    #   taxon); if false, use the observation taxon (taxon), which is the observer's
    #   own most recent ID when no community consensus exists
    # @return [Otu, nil]
    def self.stub_otu(result, project_id:, match_by_name: false, use_community_taxon: true)
      taxon_name = self.taxon_name(result, use_community_taxon:)
      return nil if taxon_name.blank?

      if match_by_name
        existing = Otu.where(project_id:)
          .left_joins(:taxon_name)
          .where('otus.name = ? OR taxon_names.cached = ?', taxon_name, taxon_name)
          .order(Arel.sql('taxon_names.id IS NULL ASC'))
          .first
        return existing if existing
      end

      Otu.new(name: taxon_name)
    end

    # Find BiocurationClass records in the project that match iNat annotations on
    # the observation, via INAT_ANNOTATION_LABEL_TO_DWC_URI → BiocurationGroup URI.
    # Only annotations with a DwC mapping are considered; unmatched annotations are skipped.
    #
    # @param result [Hash] a Nasturtium result
    # @param project_id [Integer]
    # @return [Array<BiocurationClass>]
    def self.stub_biocuration_classes(result, project_id:)
      annotations = (result['annotations'] || []).select do |a|
        a.dig('controlled_attribute', 'label').present? &&
          a.dig('controlled_value', 'label').present? &&
          INAT_ANNOTATION_LABEL_TO_DWC_URI.key?(a.dig('controlled_attribute', 'label'))
      end
      return [] if annotations.empty?

      relevant_uris = annotations.map { |a| INAT_ANNOTATION_LABEL_TO_DWC_URI[a.dig('controlled_attribute', 'label')] }.uniq
      group_ids_by_uri = BiocurationGroup
        .where(project_id:, uri: relevant_uris)
        .pluck(:uri, :id)
        .each_with_object(Hash.new { |h, k| h[k] = [] }) { |(uri, id), h| h[uri] << id }

      annotations.filter_map do |annotation|
        term_label  = annotation.dig('controlled_attribute', 'label')
        value_label = annotation.dig('controlled_value', 'label')

        group_ids = group_ids_by_uri[INAT_ANNOTATION_LABEL_TO_DWC_URI[term_label]]
        next if group_ids.blank?

        BiocurationClass
          .where(project_id:)
          .joins(:tags)
          .where(tags: { keyword_id: group_ids })
          .find_by('lower(controlled_vocabulary_terms.name) = lower(?)', value_label)
      end.compact
    end

    # Returns the iNat observation_photos that carry a CC or PD license importable into TW.
    #
    # @param result [Hash] a Nasturtium result
    # @return [Array<Hash>] observation_photo hashes (the outer object, which carries uuid)
    def self.permitted_photos(result)
      return [] if result.blank?

      (result['observation_photos'] || []).filter_map do |obs_photo|
        photo = obs_photo['photo']
        next if photo.blank?
        next unless INAT_LICENSE_CODE_TO_TW_LICENSE.key?(photo['license_code'])

        obs_photo
      end
    end

    # Returns the iNat observation_sounds that carry a CC or PD license importable into TW.
    #
    # @param result [Hash] a Nasturtium result
    # @return [Array<Hash>] observation_sound hashes (the outer object, which carries uuid)
    def self.permitted_sounds(result)
      return [] if result.blank?

      (result['observation_sounds'] || []).filter_map do |obs_sound|
        sound = obs_sound['sound']
        next if sound.blank?
        next unless INAT_LICENSE_CODE_TO_TW_LICENSE.key?(sound['license_code'])

        obs_sound
      end
    end

    # Build and save a Sound (with Attribution, copyright holder Person, and iNat identifier)
    # from an iNat observation_sound hash. Raises on failure so the caller's savepoint can roll back.
    #
    # @param obs_sound [Hash] the outer observation_sound object (carries uuid)
    # @param result [Hash] the full Nasturtium observation result (for ORCID matching)
    # @param observed_year [Integer, nil] year of observation, used as copyright year
    # @param person_cache [Hash, nil] per-import-run cache (see .dedupe_person)
    # @return [Sound]
    def self.build_sound!(obs_sound, result:, observed_year: nil, person_cache: nil)
      sound_data  = obs_sound['sound']
      license_key = INAT_LICENSE_CODE_TO_TW_LICENSE[sound_data['license_code']]

      copyright_person = stub_copyright_person(result, media: sound_data, person_cache:)
      copyright_person.save! if copyright_person.new_record?

      attribution = Attribution.new(
        license: license_key,
        copyright_year: observed_year,
        copyright_holder_roles: [
          AttributionCopyrightHolder.new(person: copyright_person)
        ]
      )

      sound = Sound.new(name: sound_data['original_filename'].presence || obs_sound['uuid'])
      tempfile = download_to_tempfile(sound_data['file_url'])
      begin
        sound.sound_file.attach(
          io: File.open(tempfile.path),
          filename: tempfile.original_filename,
          content_type: Marcel::MimeType.for(Pathname.new(tempfile.path), name: tempfile.original_filename)
        )
      ensure
        tempfile.close!
      end
      sound.attribution = attribution
      if obs_sound['uuid'].present?
        sound.identifiers << Identifier::Global::Uuid::InaturalistObservationSound.new(
          identifier: obs_sound['uuid']
        )
      end
      begin
        sound.save!
      rescue ActiveRecord::RecordInvalid
        existing = obs_sound['uuid'].present? &&
          Identifier::Global::Uuid::InaturalistObservationSound.find_by(identifier: obs_sound['uuid'])
        raise unless existing
        sound = existing.identifier_object
      end

      sound
    end

    # Find or build the copyright holder Person for a photo or sound.
    #
    # iNat auto-generates `attribution` from the uploader's account in every case we've
    # observed against the live API — *except* for photos imported into iNat from an
    # external source (e.g. Flickr), where iNat's own `attribution_name` uses that
    # source's `native_realname`/`native_username` instead, crediting the original
    # photographer rather than the iNat account that imported it. Those two fields are
    # deliberately excluded from the public API's JSON output, so the rendered
    # `attribution` string is the *only* way to recover that identity — there's no
    # structured field we could use instead. So we check whether the parsed name
    # actually is the observer rather than assuming it.
    #
    # Strategy (in order):
    #   1. If the attribution names the observer (or gives no name at all, e.g. CC0's
    #      "no rights reserved") — ORCID match first, then key off the observer's exact
    #      iNat identity.
    #   2. Otherwise, the attribution names someone else Nasturtium has no ORCID/id
    #      for (a native_realname/native_username credit) — build a Person::Unvetted
    #      from that name, weakly deduped by name within this run since that's all we
    #      have to go on.
    #
    # @param result [Hash] the full Nasturtium observation result (used for ORCID/user id lookup)
    # @param media [Hash] the photo or sound hash (used for attribution string fallback)
    # @param person_cache [Hash, nil] per-import-run cache (see .dedupe_person)
    # @return [Person]
    def self.stub_copyright_person(result, media:, person_cache: nil)
      copyright_name = parse_attribution_name(media['attribution'])
      observer_names = [result.dig('user', 'name'), result.dig('user', 'login')].map(&:presence).compact

      names_someone_else = copyright_name.present? &&
        observer_names.none? { |n| n.casecmp?(copyright_name) }

      if names_someone_else
        # Attribution names someone other than the observer (a native_realname/
        # native_username credit) — no exact identity available, weak name dedup only.
        return dedupe_person(person_from_display_name(copyright_name), person_cache)
      end

      matched = person_by_orcid(result)
      return dedupe_person(matched, person_cache, result) if matched

      # Neither the attribution nor the observer's own account gives us a name at
      # all (e.g. CC0 with a blank user.name/login) - build the placeholder
      # directly, bypassing BibTeX name-parsing, which would otherwise mangle it.
      name = copyright_name || observer_names.first
      person = name ? person_from_display_name(name) : Person::Unvetted.new(last_name: 'Undetermined iNaturalist user')

      dedupe_person(person, person_cache, result)
    end

    # Parse the photographer's name out of an iNat-generated attribution string, e.g.
    #   "(c) Kim, Hyun-tae, some rights reserved (CC BY-NC-SA)" => "Kim, Hyun-tae"
    #   "(c) Jane Doe, all rights reserved" => "Jane Doe"
    #   "no rights reserved" (CC0 - no name given) => nil
    #
    # @param attribution [String, nil]
    # @return [String, nil]
    def self.parse_attribution_name(attribution)
      return nil if attribution.blank?

      m = attribution.match(/\A\(c\)\s+(.+),\s*(?:some|all)\s+rights reserved/)
      return nil unless m

      m[1].squeeze(' ').strip
    end

    # Build and save an Image (with Attribution, copyright holder Person, and iNat identifier)
    # from an iNat photo hash.  Raises on failure so the caller's savepoint can roll back.
    #
    # @param photo [Hash] the 'photo' object from an iNat observation_photo
    # @param result [Hash] the full Nasturtium observation result (for ORCID matching)
    # @param observed_year [Integer, nil] year of observation, used as copyright year
    # @param person_cache [Hash, nil] per-import-run cache (see .dedupe_person)
    # @return [Image]
    def self.build_image!(obs_photo, result:, observed_year: nil, person_cache: nil)
      photo = obs_photo['photo']
      license_key = INAT_LICENSE_CODE_TO_TW_LICENSE[photo['license_code']]

      copyright_person = stub_copyright_person(result, media: photo, person_cache:)
      copyright_person.save! if copyright_person.new_record?

      attribution = Attribution.new(
        license: license_key,
        copyright_year: observed_year,
        copyright_holder_roles: [
          AttributionCopyrightHolder.new(person: copyright_person)
        ]
      )

      image_url = large_photo_url(photo['url'])
      tempfile = download_to_tempfile(image_url)
      begin
        image = Image.new(image_file: tempfile)
        image.attribution = attribution
        if obs_photo['uuid'].present?
          image.identifiers << Identifier::Global::Uuid::InaturalistObservationPhoto.new(
            identifier: obs_photo['uuid']
          )
        end
        begin
          image.save!
        rescue ActiveRecord::RecordInvalid
          existing = Image.find_by(image_file_fingerprint: image.image_file_fingerprint)
          raise unless existing
          image = existing
        end
      ensure
        tempfile.close!
      end

      image
    end

    # Build a Person::Unvetted from a display name string.
    # Multi-word names (e.g. "Greg Lasley") are parsed via BibTeX so that
    # first/last are split correctly.  Single-word strings (login slugs or
    # single-name users) go directly into last_name unchanged.
    #
    # @param name [String]
    # @return [Person::Unvetted]
    def self.person_from_display_name(name)
      return Person::Unvetted.new(last_name: name) unless name.include?(' ')

      Person.parse_to_people(name).first || Person::Unvetted.new(last_name: name)
    end

    # @param photo_url [String] iNat square thumbnail URL
    # @return [String] URL for the large version
    def self.large_photo_url(photo_url)
      return nil if photo_url.blank?

      photo_url.sub('/square.', '/large.')
    end

    # Download a remote image to a Tempfile with the original_filename method
    # that Paperclip expects.
    #
    # @param url [String]
    # @return [Tempfile]
    def self.download_to_tempfile(url)
      uri_path = URI.parse(url).path
      tempfile = Tempfile.new(['inat_media', File.extname(uri_path)], binmode: true)

      URI.open(url, 'rb') { |io| tempfile.write(io.read) }
      tempfile.rewind

      basename = File.basename(uri_path)
      tempfile.define_singleton_method(:original_filename) { basename }

      tempfile
    end

  end

end
