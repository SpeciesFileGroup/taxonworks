require 'open-uri'

module Vendor

  #  a = Nasturtium.observations(id: '99182856')

  # Possible Extensions
  #  * iNaturalist has UUID for identifications, this could be linked to a TaxonDetermination with a Identifier::Global::Uuid::InaturalistIdentification

  # From an oID
  #   - CE with a iNat global UUID
  #   - Georeference on that CE
  #
  #   - place_guess -> as verbatim_locality option
  #
  #   - Person reference wikidata/orcid ID on people
  #   - mock collectors
  #
  #   - mock georeferencers
  #
  #   - image is importable (check attribution?)
  #   - set attribution
  #   - ... virtually display images ?!
  #
  #   - Bonus set GA for CE based on string matching
  #    - consider prioritization meta being set
  #
  #  - predict_otu
  #
  # A middle-layer wrapper between Nasturtium and TaxonWorks
  module Nasturtium

    # Maps iNaturalist photo license_code values to CREATIVE_COMMONS_LICENSES keys.
    # Derived from the inat_codes entries in CREATIVE_COMMONS_LICENSES.
    # iNat codes not in this map (e.g. nil, 'arr') are not importable.
    INAT_LICENSE_CODE_TO_TW_LICENSE = CREATIVE_COMMONS_LICENSES
      .each_with_object({}) { |(k, v), h| h[v[:inat_code]] = k if v[:inat_code] }
      .freeze

    # Fetch multiple observations in a single iNat API request.
    # IDs are joined as a comma-separated string because Faraday serializes
    # Ruby arrays as id[]=...&id[]=... which the iNat API does not accept.
    #
    # @param ids [Array<String>] iNat observation integer IDs
    # @return [Array<Hash>] Nasturtium result hashes (only found observations are returned)
    def self.by_observation_ids(ids)
      return [] if ids.blank?

      ::Nasturtium.observations(id: ids.join(','), per_page: ids.size)['results']
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

    # Find or build the observer as a Person for use as a TaxonDetermination determiner.
    # Strategy: ORCID match first, then Person::Unvetted from user.name or user.login.
    #
    # @param result [Hash] a Nasturtium result
    # @return [Person]
    def self.stub_determiner(result)
      person_by_orcid(result) ||
        Person::Unvetted.new(last_name: result.dig('user', 'name').presence || result.dig('user', 'login'))
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
      (result['annotations'] || []).filter_map do |annotation|
        term_label  = annotation.dig('controlled_attribute', 'label')
        value_label = annotation.dig('controlled_value', 'label')
        next if term_label.blank? || value_label.blank?

        dwc_uri = INAT_ANNOTATION_LABEL_TO_DWC_URI[term_label]
        next unless dwc_uri

        group_ids = BiocurationGroup.where(project_id:, uri: dwc_uri).pluck(:id)
        next if group_ids.empty?

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
    # @return [Array<Hash>] photo hashes (the nested 'photo' object from each observation_photo)
    def self.permitted_photos(result)
      return [] if result.blank?

      (result['observation_photos'] || []).filter_map do |obs_photo|
        photo = obs_photo['photo']
        next if photo.blank?
        next unless INAT_LICENSE_CODE_TO_TW_LICENSE.key?(photo['license_code'])

        photo
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
    # @return [Sound]
    def self.build_sound!(obs_sound, result:, observed_year: nil)
      sound_data  = obs_sound['sound']
      license_key = INAT_LICENSE_CODE_TO_TW_LICENSE[sound_data['license_code']]

      copyright_person = stub_copyright_person(result, media: sound_data)
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
          content_type: sound_data['file_content_type'],
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
      sound.save!

      sound
    end

    # Find or build the copyright holder Person for a photo or sound.
    #
    # Strategy (in order):
    #   1. ORCID match — if the observer has an ORCID and a matching Person exists in TW, use them.
    #   2. Name fallback — parse the attribution string for a name and create a new Person::Unvetted.
    #
    # @param result [Hash] the full Nasturtium observation result (used for ORCID lookup)
    # @param media [Hash] the photo or sound hash (used for attribution string fallback)
    # @return [Person]
    def self.stub_copyright_person(result, media:)
      # 1. Try ORCID
      matched = person_by_orcid(result)
      return matched if matched

      # 2. Name fallback from attribution string, e.g.
      #    "(c) username, some rights reserved (CC BY-NC)" → "username"
      copyright_name = if media['attribution'] =~ /\(c\)\s+(.+?),/
        $1.strip
      else
        media['attribution'].presence || 'Unknown'
      end

      Person::Unvetted.new(last_name: copyright_name)
    end

    # Build and save an Image (with Attribution, copyright holder Person, and iNat identifier)
    # from an iNat photo hash.  Raises on failure so the caller's savepoint can roll back.
    #
    # @param photo [Hash] the 'photo' object from an iNat observation_photo
    # @param result [Hash] the full Nasturtium observation result (for ORCID matching)
    # @param observed_year [Integer, nil] year of observation, used as copyright year
    # @return [Image]
    def self.build_image!(photo, result:, observed_year: nil)
      license_key = INAT_LICENSE_CODE_TO_TW_LICENSE[photo['license_code']]

      copyright_person = stub_copyright_person(result, media: photo)
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
        if photo['uuid'].present?
          image.identifiers << Identifier::Global::Uuid::InaturalistObservationPhoto.new(
            identifier: photo['uuid']
          )
        end
        image.save!
      ensure
        tempfile.close!
      end

      image
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
