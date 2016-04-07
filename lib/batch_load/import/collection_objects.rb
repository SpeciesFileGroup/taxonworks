module BatchLoad
  # TODO: Originally transliterated from Import::AssertedDistributions: Remove this to-do after successful operation.
  class Import::CollectionObjects < BatchLoad::Import

    attr_accessor :collection_objects

    def initialize(**args)
      @collection_objects = {}
      super(args)
    end

    # process each row for information:
    def build_collection_objects
      i   = 1 # accounting for headers
      # identifier namespace
      n_s = Namespace.find_or_create(name: row[1][0])
      csv.each do |row|
        i += 1

        ident = Identifier.find_or_create(identifier: row[0],
        )
        otu   = Otu.find_or_create(name: row[2])
        c_e   = CollectingEvent.find(row[4])
        gr    = GeoLocate.new()

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

