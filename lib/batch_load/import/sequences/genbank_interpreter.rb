# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::Sequences::GenbankInterpreter < BatchLoad::Import
    include BatchLoad::Helpers::Sequences

    def initialize(**args)
      @sequences = {}
      super(args)
    end

    # TODO: update this
    def build_sequences

      i = 1
      # loop throw rows
      csv.each do |row|

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:sequence] = []
        parse_result.objects[:origin_relationship] = []

        @processed_rows[i] = parse_result

        begin # processing
          # use a BatchLoad::ColumnResolver or other method to match row data to TW 
          #  ...

          sequence = create_sequence(row["filename"], row["file_content"])
          parse_result.objects[:sequence].push(sequence)

          origin_relationship = create_origin_relationship(row["filename"], sequence)
          parse_result.objects[:origin_relationship].push(sequence) if sequence
        #rescue
           # ....
        end
        i += 1
      end
    end

    def build
      if valid?
        build_sequences
        @processed = true
      end
    end

  end
end
