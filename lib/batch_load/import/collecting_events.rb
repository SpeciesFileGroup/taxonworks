module BatchLoad
  # TODO: Originally transliterated from Import::AssertedDistributions: Remove this to-do after successful operation.
  class Import::CollectingEvents < BatchLoad::Import

    attr_accessor :collecting_events

    attr_accessor :ce_namespace

    # @param [Hash] args
    def initialize(ce_namespace: nil, **args)
      @collecting_events = {}
      @ce_namespace      = ce_namespace
      super(**args)
    end

    # @return [Hash]
    def preview_collecting_events
      @preview_table = {}

      @preview_table
    end

    # rubocop:disable Metrics/MethodLength
    # process each row for information:
    # @return [Integer]
    def build_collecting_events
      i = 1 # accounting for headers
      # identifier namespace
      header0 = csv.headers[0] # should be 'collection_object_identifier_namespace_short_name'
      header1 = csv.headers[1] # should be 'collection_object_identifier_identifier'
      header5 = csv.headers[5] # should be 'collecting_event_identifier_namespace_short_name'
      header6 = csv.headers[6] # should be 'collecting_event_identifier_identifier'
      header7 = csv.headers[7] # should be 'collecting_event_identifier_type'
      csv.each do |row|
        co_namespace = row[header0]
        co_id        = row[header1]
        next if (co_namespace.nil? or co_id.nil?) # no namespace to search!
        # find a namespace (ns1) with a short_name of row[headers[0]] (id1)
        # find a collection_object which has an identifier which has a namespace (ns1), and a cached of
        # (ns1.short_name + ' ' + identifier.identifier)
        # ns1    = Namespace.where(short_name: id1).first
        long         = row['longitude'] # longitude
        lat          = row['latitude'] # latitude
        method       = row['method']
        error        = (row['error'].to_s + ' ' + row['georeference_error_units'].to_s).strip
        ce_namespace = row[header5]
        co           = CollectionObject.joins(:identifiers).where(identifiers: {cached: "#{co_namespace} #{co_id}"}).first
        otu          = Otu.find_or_create_by!(name: row['otu'])
        td           = TaxonDetermination.find_or_create_by!(otu:                          otu,
                                                             biological_collection_object: co)
        ce           = CollectingEvent.find_or_create_by!(verbatim_locality:                row['verbatim_location'],
                                                          verbatim_geolocation_uncertainty: error,
                                                          verbatim_date:                    row['verbatim_date'],
                                                          start_date_day:                   row['start_date_day'],
                                                          start_date_month:                 row['start_date_month'],
                                                          start_date_year:                  row['start_date_year'],
                                                          end_date_day:                     row['end_date_day'],
                                                          end_date_month:                   row['end_date_month'],
                                                          end_date_year:                    row['end_date_year'],
                                                          verbatim_longitude:               long,
                                                          verbatim_latitude:                lat,
                                                          verbatim_method:                  method)
        ce.save!
        case method.downcase
          when 'geolocate'
            # faking a Georeference::GeoLocate:
            #   1) create the Georeference, using the newly created collecting_event
            gr = Georeference::GeoLocate.create!(collecting_event: ce)
            #   2) build a fake iframe response in the form '52.65|-106.333333|3036|Unavailable'
            text = "#{lat}|#{long}|#{Utilities::Geo.distance_in_meters(error).to_f}|Unavailable"
            #   3) use that fake to stimulate the parser to create the object
            gr.iframe_response = text
            gr.save
          else
            # nothing to do?
        end unless method.nil?

        ns_ce = Namespace.where(short_name: ce_namespace).first
        ce_id = Identifier.new(namespace:  ns_ce,
                               type:       'Identifier::' + row[header7],
                               identifier: row[header6])
        ce.identifiers << ce_id
        co.collecting_event = ce
        i                   += 1
      end
      @total_lines = i - 1
    end
    # rubocop:enable Metrics/MethodLength

    # @return [Boolean]
    def build
      if valid?
        build_collecting_events
        @processed = true
      end
    end
  end
end

