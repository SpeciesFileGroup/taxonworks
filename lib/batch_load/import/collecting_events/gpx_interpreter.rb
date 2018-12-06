# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::CollectingEvent::GpxInterpreter < BatchLoad::Import

    def initialize(**args)
      @collecting_events = {}
      super(args)
    end

    # TODO: update this
    def build_collecting_events
      @total_data_lines = 0
      i = 0

      # loop throw rows
      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:collecting_event] = []

        @processed_rows[i] = parse_result

        begin # processing
          # use a BatchLoad::ColumnResolver or other method to match row data to TW
          #  ...

          @total_data_lines += 1
        rescue
           # ....
        end
      end

      @total_lines = i
    end

    def build
      if valid?
        build_collecting_events
        @processed = true
      end
    end
  end
  # gpx = GPX::GPXFile.new(:gpx_file => '/Users/tuckerjd/src/taxonworks/spec/files/batch/collecting_event/test.gpx')
end
