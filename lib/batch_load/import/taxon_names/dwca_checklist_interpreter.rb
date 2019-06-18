module BatchLoad
  class Import::TaxonName::DwcaChecklistInterpreter < BatchLoad::Import

    def initialize(**args)
      @taxon_names = {}
      super(args)
    end

    # TODO: update this
    def build_taxon_names
      @total_data_lines = 0
      i = 0

      # loop through rows
      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:taxon_name] = []

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
        build_taxon_names
        @processed = true
      end
    end
  end
end
