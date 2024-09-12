module Vendor


  #  a = Nasturtium.observations(id: '99182856')

  # Possible Extenions
  #  * iNaturalist has UUID for identifications, this could linked a TaxonDetermination with a Identifier::Global::Uuid::InaturalistIdentification


  # From an oID
  #   - CE with a iNatu global UUID
  #   - Georeference on that ce
  #
  #   - place_guess -> as verbatim_locality option
  #
  #   - Person reference wikidata/orcid ID on people
  #   - mock collectora
  #
  #   - mock georeferencers
  #
  #   - image is importable (check attribution?
  #   - set attribution
  #   - ... virtually display images ?!
  #
  #   - Bonus set GA for Ce based on string matching
  #    - consider prioritization meta being set
  #
  #  - predict_otu
  #
  # A middle-layer wrapper between Nasturtium and TaxonWorks
  module Nasturtium

    #  @return Array of Nasturium 'results'
    #  @param id Integer
    #    an iNat observation ID
    def self.by_observation_id(id = nil)
      return [] if id.nil?

      # We are assuming there is only 1 paginated result when hit by observation id
      ::Nasturtium.observations(id:)['results'].first
    end

    def stub_field_occurrence(result)
      return nil if result.blank?
      FieldOccurrence.new(
        total: 1,
        collecting_event: stub_collecting_event(result),
      )
    end

    def self.stub_collecting_event(result, guess_as_locality: true)
      return nil if result.blank?

      d = result['observed_on_details']

      p = {
        verbatim_collectors: result.dig('user', 'name').presence,
        start_date_day: d['day'],
        start_date_month: d['month'],
        start_date_year: d['year'],
        time_start_hour: d['hour'],
      }

      p[:verbatim_locality] = result['place_guess'] if guess_as_locality

      return nil if result.blank?
      CollectingEvent.new(
        p.merge(
          georeferences: [stub_georeference(result)],
          #       identifiers: [stub_collecting_event_identifier(result)]
        )
      )
    end

    def self.stub_collecting_event_identifier(result)
      nil
    end

    def self.stub_collector(result)

      orcid = result.dig('user', 'orcid')
      name = result.dig('user', 'name')

      # TODO: add to people logic
      Person.new( orcid:, name: )

      nil

      # orcid ID is provide for some
      # also "name" for some
      #
      # Use DwcAgent to parse name
      #   stub a Person virtual attribute for this
      #
      # Lookup Person from orcid
      #   stub virtual method for this too
      #
    end

    def self.stub_georeference(result)
      return nil if result.blank?

      c = result.dig('geojson', 'coordinates')

      return nil if c.blank?

      Georeference::Inaturalist.new(
        error_radius: result['positional_accuracy'],
        geographic_item_attributes: {
          type: 'GeographicItem::Point',
          point: "POINT(#{c.first} #{c.second})"
        }
      )

    end

    def self.stub_images(result)
    end

    #   def self.stub_collectors(result)
    #   end

  end

end
