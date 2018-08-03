# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::Otu::DataAttributesInterpreter < BatchLoad::Import

    # @param [Hash] args
  def initialize(**args)
      super(args)
    end

    # TODO: update this
    def build_otus
      @total_data_lines = 0
      i = 0

      # loop throw rows
      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:otu] = []

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
        build_otus
        @processed = true
      end
    end
  end
end
