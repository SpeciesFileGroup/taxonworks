# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::CollectionObjects::SpecimenInterpreter < BatchLoad::Import

    def initialize(**args)
      @collection_objects = {}
      super(args)
    end

    # TODO: update this
    def build_collection_objects

      i = 1
      # loop throw rows
      csv.each do |row|

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:collection_object] = []

        @processed_rows[i] = parse_result

        begin # processing
           # use a BatchLoad::ColumnResolver or other method to match row data to TW 
           #  ...
           
        rescue
           # ....
        end
        i += 1
      end
    end

    def build
      if valid?
        build_collection_objects
        @processed = true
      end
    end

  end
end
