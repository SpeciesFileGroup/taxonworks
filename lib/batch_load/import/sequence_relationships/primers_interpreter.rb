# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::SequenceRelationships::PrimersInterpreter < BatchLoad::Import

    def initialize(**args)
      @sequence_relationships = {}
      super(args)
    end

    # TODO: update this
    def build_sequence_relationships
      @total_data_lines = 0
      i = 0

      # loop throw rows
      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:sequence_relationship] = []

        @processed_rows[i] = parse_result

        begin # processing
          sequence_id = row["identifier"]
          primers = get_primers(row["primers"])


          primers.each do |primer|
            sequences = Sequence.with_namespaced_identifier("DRMSequenceId", sequence_id)
            sequence = nil
            sequence = sequences.first if sequences.any?

            if sequence
              primer_sequence = get_primer_sequence(primer)

              if primer_sequence
                sequence_relationship = SequenceRelationship.new({
                  subject_sequence: primer_sequence,
                  object_sequence: sequence,
                  type: get_relationship_type(primer_sequence)
                })

                parse_result.objects[:sequence_relationship].push(sequence_relationship)
              end
            end
          end
        # rescue
        end
      end

      @total_lines = i
    end

    def build
      if valid?
        build_sequence_relationships
        @processed = true
      end
    end

    def get_primers(primers)
      primers.split(",")
    end

    def get_relationship_type(primer)
      data_attributes = primer.import_attributes

      data_attributes.each do |data_attribute|
        if data_attribute.import_predicate === "Type"
          value = data_attribute.value

          if value === "F"
            return "SequenceRelationship::ForwardPrimer"
          elsif value === "R"
            return "SequenceRelationship::ReversePrimer"
          end
        end
      end
    end

    def get_primer_sequence(primer_name)
      sequences = Sequence.with_any_value_for(:name, primer_name)
      sequence = nil
      sequence = sequences.first if sequences.any?
    end
  end
end
