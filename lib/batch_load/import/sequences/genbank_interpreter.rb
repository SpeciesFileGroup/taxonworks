module BatchLoad
  class Import::Sequences::GenbankInterpreter < BatchLoad::Import
    include BatchLoad::Helpers::Sequences

    # @param [Hash] args
    def initialize(**args)
      @sequences = {}
      super(**args)
    end

    # TODO: update this
    # @return [Integer]
    def build_sequences
      @total_data_lines = 0
      i = 0
      # loop through rows
      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:sequence] = []
        parse_result.objects[:origin_relationship] = []

        @processed_rows[i] = parse_result

        begin # processing
          # use a BatchLoad::ColumnResolver or other method to match row data to TW
          #  ...

          sequence = create_sequence(row['filename'], row['file_content'])
          parse_result.objects[:sequence].push(sequence)

          origin_relationship = create_origin_relationship(row['filename'], sequence)
          parse_result.objects[:origin_relationship].push(origin_relationship) if origin_relationship
          @total_data_lines += 1 if sequence.present?
        #rescue
           # ....
        end
      end

      @total_lines = i
    end

    # @return [Boolean]
    def build
      if valid?
        build_sequences
        @processed = true
      end
    end

  end
end
