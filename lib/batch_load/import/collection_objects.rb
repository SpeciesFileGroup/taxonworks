module BatchLoad
  # TODO: Originally transliterated from Import::AssertedDistributions: Remove this to-do after successful operation.
  class Import::CollectionObjects < BatchLoad::Import

    attr_accessor :collection_objects

    attr_accessor :namespace

    def initialize(**args)
      @collection_objects = {}
      super(args)
    end

    # process each row for information:
    def build_collection_objects
      i          = 1 # accounting for headers
      # identifier namespace
      local_name = csv.headers[0]
      ns1        = Namespace.where(short_name: local_name).first
      ns2 - Namespace.first_or_create(name: 'Arbitrary Name', short_name: 'ns2')
      id1 - row[local_name]
      csv.each do |row|
        # find a namespace (ns1) with a short_name of headers[0] (local_name)
        # find a collection_object which has an identifier which has a namespace (ns1), and a cached of
        # (ns1.short_name + ' ' + identifier.identifier)
        co  = CollectionObject.joins(:identifiers).where(identifiers: {cached: "#{ns1.short_name} #{id1}"}).first
        otu = Otu.find_or_create_by(name: row[2])
        td  = TaxonDetermination.create(otu:               otu,
                                        collection_object: co)
        ce  = CollectingEvent.create(verbatim_locality:                row['verbatim_location'],
                                     verbatim_geolocation_uncertainty: row['error'],
                                     verbatim_date:                    row['date'],
                                     start_date_day:                   row['day'],
                                     start_date_month:                 row['month'],
                                     start_date_year:                  row['year'],
                                     verbatim_longitude:               row['longitude'],
                                     verbatim_latitude:                row['latitude'],
                                     verbatim_method:                  row['method'])
        gr  = Georeference.create(collecting_event: ce,
                                  type:             'Georeference::GeoLocate')

        co.collecting_ecent = ce

        Identifier::Local::TripCode.new(namespace: ns2, identifier: row['collecting event #'])
        # error_radius:     Utilities::Geo.elevation_in_meters(row['error']))
        # ident = Identifier.find_or_create_by(identifier:   row[0],
        #                                      namespace_id: n_s.id,
        #                                      type:         'Identifier::Local::Import',
        # )

        i += 1
      end
      @total_lines = i - 1
    end

    def build
      if valid?
        build_collection_objects
        @processed = true
      end
    end
  end
end

