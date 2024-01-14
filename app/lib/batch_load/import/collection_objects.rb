require 'digest/bubblebabble'

module BatchLoad
  class Import::CollectionObjects < BatchLoad::Import

    attr_accessor :collection_objects
    attr_accessor :collecting_events
    attr_accessor :taxon_determinations
    attr_accessor :otus

    attr_accessor :namespace

    # @param [Hash] args
    def initialize(**args)
      @collection_objects   = {}
      @collecting_events    = {}
      @taxon_determinations = {}
      @otus                 = {}
      super(**args)
    end

    # rubocop:disable Metrics/MethodLength
    # @return [Integer]
    def build_collection_objects
      # test_build
      build_objects = {}
      i             = 1 # accounting for headers
      # identifier namespace
      header5       = csv.headers[5] # should be 'collecting_event_identifier_namespace_short_name'
      header6       = csv.headers[6] # should be 'collecting_event_identifier_identifier'
      header7       = csv.headers[7] # should be 'collecting_event_identifier_type'
      #
      # first pass for CollectingEvent with Georeference and Identifier
      csv.each do |row|
        parse_result = BatchLoad::RowParse.new
        # creation of the possible-objects list
        parse_result.objects.merge!(co: [], otu: [], td: [], ce: [])
        # attach the results to the row
        @processed_rows[i] = parse_result

        # hot-wire the project into the row
        temp_row               = row
        temp_row['project_id'] = @project_id.to_s if row['project_id'].blank?

        begin # processing the CollectionObject
          co_list = BatchLoad::ColumnResolver.collection_object_by_identifier(temp_row)
          if co_list.no_matches? # no namespace to search!
            parse_result.parse_errors.push(co_list.error_messages.first)
            i += 1 # can't skip the increment!
            next
          end
          co = co_list.item # there can be only one
          unless co.collecting_event.nil? # if it exists
            parse_result.parse_errors.push('The specified CollectionObject already has a CollectingEvent.')
            i += 1 # can't skip the increment!
            next
          end
          parse_result.objects[:co].push(co)
        end

        begin # processing the Otu
          otu            = nil
          otu_attributes = {name: row['otu_name']}
          otu_list       = BatchLoad::ColumnResolver.otu(temp_row)
          otu            = otu_list.item if otu_list.resolvable?
          otu_match      = Digest::SHA256.digest(otu_attributes.to_s)
          otu            = build_objects[otu_match] if otu.blank?
          otu            = Otu.new(otu_attributes) if otu.blank?
          build_objects[otu_match] = otu # .merge!(otu_match => otu)
          parse_result.objects[:otu].push(otu)
        end

        begin # processing the TaxonDetermination
          td_attributes = {otu:                          otu,
                           biological_collection_object: co}
          # td_match      = Digest::SHA256.digest(td_attributes.to_s)
          # td            = build_objects[td_match]
          # td            = TaxonDetermination.find_by(td_attributes) if td.nil?
          td            = TaxonDetermination.new(td_attributes)
          parse_result.objects[:td].push(td)
          # build_objects.merge!(td_match => td)
        end

        begin # processing the CollectingEvent
          id_ce    = row[header6]
          vert_loc = row['verbatim_location']
          long     = row['longitude'] # longitude
          lat      = row['latitude'] # latitude
          method   = row['method']
          error    = (row['error'].to_s + ' ' + row['georeference_error_units'].to_s).strip

          ce_namespace = row[header5]
          ns_ce        = Namespace.where(short_name: ce_namespace).first
          parse_result.parse_errors.push("No available namespace '#{ce_namespace}'.") if ns_ce.nil?

          # force a verbatim_locality, if none is provided.
          if vert_loc.blank?
            vert_loc = "#{ns_ce.short_name} #{id_ce}"
          end
          ce_attributes = {verbatim_locality:                vert_loc,
                           verbatim_geolocation_uncertainty: error.empty? ? nil : error,
                           start_date_day:                   row['start_date_day'],
                           start_date_month:                 row['start_date_month'],
                           start_date_year:                  row['start_date_year'],
                           end_date_day:                     row['end_date_day'],
                           end_date_month:                   row['end_date_month'],
                           end_date_year:                    row['end_date_year'],
                           verbatim_longitude:               long,
                           verbatim_latitude:                lat,
                           verbatim_method:                  method,
                           geographic_area_id:               nil,
                           minimum_elevation:                nil,
                           maximum_elevation:                nil,
                           elevation_precision:              nil,
                           field_notes:                      nil,
                           verbatim_elevation:               nil,
                           verbatim_habitat:                 nil,
                           verbatim_datum:                   nil,
                           time_start_hour:                  nil,
                           time_start_minute:                nil,
                           time_start_second:                nil,
                           time_end_hour:                    nil,
                           time_end_minute:                  nil,
                           time_end_second:                  nil,
                           verbatim_date:                    row['verbatim_date'],
                           verbatim_trip_identifier:         nil,
                           verbatim_collectors:              nil,
                           verbatim_label:                   nil,
                           document_label:                   nil,
                           print_label:                      nil,
                           project_id:                       @project_id
          }

          ce_id_attributes = {identifiers_attributes: [{namespace:  ns_ce,
                                                        project_id: @project_id,
                                                        type:       'Identifier::' + row[header7],
                                                        identifier: id_ce}]}
          id_attributes    = ce_id_attributes[:identifiers_attributes][0]
          ce_key           = ce_attributes.merge(ce_id_attributes)
          # id_match         = Digest::SHA256.digest(ce_id_attributes.to_s)

          gr_attributes    = {}
          case method.downcase
            when 'geolocate'
              gr_attributes = {geo_locate_georeferences_attributes: [{iframe_response: "#{lat}|#{long}|#{Utilities::Geo.distance_in_meters(error).to_f}|Unavailable"}]}
            else
          end unless method.nil?

          case row[1]
            when '35397', '38866'
              ce_a1 = ce_attributes
              ce_m1 = Digest::SHA256.digest(ce_key.to_s)
            else
          end

          ce_match = Digest::SHA256.digest(ce_key.to_s)
          ce       = build_objects[ce_match]
          ce       = CollectingEvent.includes(:identifiers).find_by(ce_attributes, id_attributes) if ce.nil?
          # ce       = CollectingEvent.find_by(ce_attributes) if ce.nil?
          ce       = CollectingEvent.new(ce_key.merge(gr_attributes)) if ce.nil?

          if ce.valid? # various different possible errors.
            co.collecting_event = ce
            parse_result.objects[:ce].push(ce)
            build_objects.merge!(ce_match => ce)
          else
            err_list = 'Collecting event problems: '
            ce.errors.messages.each { |msg|
              msg.each { |key, value|
                err_list += "#{key}: #{value}"
              }
            }
            parse_result.parse_errors.push(err_list)
            # parse_result.parse_errors.push("Identifier '#{id_test.namespace} #{id_test.identifier}'
            # has been used for a different collecting event.")
          end
        end

        i += 1
      end
      @total_lines = i - 1

    end

    def test_build
      file_name = 'spec/files/batch/collection_object/CollectionObjectTest.tsvP'
      ns_1      = Namespace.find_by(short_name: 'PSUC')
      csv1      = CSV.read(file_name, {headers: true, header_converters: :downcase, col_sep: "\t", encoding: 'UTF-8'})

      csv1.each do |row|
        # the following invocation also creates a valid specimen as a collection_object
        # FactoryBot.create(:valid_identifier, namespace: ns_1, identifier: ident)
        co = CollectionObject.new(type: 'Specimen', total: 1, preparation_type_id: 5)
        id = Identifier.new(namespace:  ns_1,
                            type:       'Identifier::Local::CatalogNumber',
                            identifier: row[1])
        co.identifiers << id

        if co.valid?
          co.save
        end
      end
    end

    # rubocop:disable Metrics/MethodLength
    # process each row for information:
    # @return [Integer]
    def build_collection_objects_ori
      ce_a1         = ''
      ce_m1         = ''
      ce1           = CollectingEvent.find(1)
      # here we store the attributes of stuff we want to find later
      build_objects = {}
      i             = 1 # accounting for headers
      # identifier namespace
      # header0 = csv.headers[0] # should be 'collection_object_identifier_namespace_short_name'
      # header1 = csv.headers[1] # should be 'collection_object_identifier_identifier'
      header5       = csv.headers[5] # should be 'collecting_event_identifier_namespace_short_name'
      header6       = csv.headers[6] # should be 'collecting_event_identifier_identifier'
      header7       = csv.headers[7] # should be 'collecting_event_identifier_type'
      csv.each do |row|
        parse_result                 = BatchLoad::RowParse.new
        # creation of the possible-objects list
        parse_result.objects[:otu]   = []
        parse_result.objects[:co]    = []
        parse_result.objects[:td]    = []
        parse_result.objects[:ce]    = []
        parse_result.objects[:gr]    = []
        parse_result.objects[:ce_id] = []
        # attach the results to the row
        @processed_rows.merge!(i => parse_result)

        # hot-wire the project into the row
        row['project_id'] = @project_id.to_s if row['project_id'].blank?

        co_list  = BatchLoad::ColumnResolver.collection_object_by_identifier(row)
        otu_list = BatchLoad::ColumnResolver.otu(row)
        if co_list.no_matches? # no namespace to search!
          parse_result.parse_errors.push('No CollectionObject found with the specified identifier.')
          next
        end
        co = co_list.item # there can be only one
        unless co.collecting_event.nil? # if it exists
          parse_result.parse_errors.push('The specified CollectionObject already has a CollectingEvent.')
          next
        end
        parse_result.objects[:co].push(co)
        otu = otu_list.item if otu_list.resolvable?
        otu = Otu.new(name: row['otu_name']) if otu.blank?
        parse_result.objects[:otu].push(otu)
        long         = row['longitude'] # longitude
        lat          = row['latitude'] # latitude
        method       = row['method']
        error        = (row['error'].to_s + ' ' + row['georeference_error_units'].to_s).strip
        ce_namespace = row[header5]
        ns_ce        = Namespace.where(short_name: ce_namespace).first
        parse_result.parse_errors.push["No available namespace '#{ce_namespace}'."] if ns_ce.nil?

        begin # processing the TaxonDetermination
          td_attributes = {otu:                          otu,
                           biological_collection_object: co}
          td_match      = Digest::SHA256.digest(td_attributes.to_s)
          td            = build_objects[td_match]
          td            = TaxonDetermination.find_by(td_attributes) if td.nil?
          td            = TaxonDetermination.new(td_attributes) if td.nil?
          parse_result.objects[:td].push(td)
          build_objects.merge!(td_match => td)
        end

        begin # processing Identifier
          ce_id_attributes = {namespace:              ns_ce,
                              identifier_object_type: 'CollectingEvent',
                              project_id:             @project_id,
                              type:                   'Identifier::' + row[header7],
                              identifier:             row[header6]}
          ce_id_match      = Digest::SHA256.digest(ce_id_attributes.to_s)
          ce_id            = build_objects[ce_id_match]
          ce_id            = Identifier.find_by(ce_id_attributes) if ce_id.nil?
          ce_id            = Identifier.new(ce_id_attributes) if ce_id.nil?
          parse_result.objects[:ce_id].push(ce_id)
          build_objects.merge!(ce_id_match => ce_id) # whichever way we came by it, save the item in our stash
        end

        co.collecting_event = ce
        i                   += 1
      end
      @total_lines = i - 1
    end
    # rubocop:enable Metrics/MethodLength

    # @return [Boolean]
    def build
      if valid?
        build_collection_objects
        @processed = true
      end
    end
  end
end

