module BatchLoad
  class Import::Sequences::PrimersInterpreter < BatchLoad::Import

    # @param [Hash] args
    def initialize(**args)
      @sequences = {}
      super(**args)
    end

    # TODO: update this
    # @return [Integer]
    def build_sequences
      @total_data_lines = 0;

      sequences = {}
      sequence_values = {}
      i = 0

      # loop through rows
      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:sequence] = []

        @processed_rows[i] = parse_result

        begin # processing
          # Check for duplicates of names of sequences, ignore them
          # Check for duplicates of actual sequence, duplicates become alternative name
          # Official names are first ones encounter
          # ? in actual sequence become ‘N’
          # Ignore ‘;’ at the end of actual sequence

          name = row['name']
          gene_name = row['gene_name']
          type = row['type']
          sequence = row['sequence'] || ''

          # Replace '?' with 'N' and remove ';' from sequence
          sequence.gsub!(/\?/, 'N')
          sequence.gsub!(/;/, '')

          if sequences.key?(name) || sequence.blank?
            next
          elsif sequence_values.key?(sequence)
            official_name = sequence_values[sequence]
            sequences[official_name][:alternate_names].push(name)
          else
            sequence_values[sequence] = name
            sequences[name] = {
              official_name: name,
              alternate_names: [],
              type: type,
              gene_name: gene_name,
              sequence: sequence,
              index: i
            }
          end

          @total_data_lines += 1
        #rescue
        end
      end

      @total_lines = i

      sequences.each_value do |sequence_obj|
        # Sequence attributes
        sequence_attributes = {
          name: sequence_obj[:official_name],
          sequence_type: 'DNA',
          sequence: sequence_obj[:sequence],
          alternate_values_attributes: [],
          data_attributes_attributes: []
        }

        # AlternateValues attributes
        sequence_obj[:alternate_names].each do |alternate_name|
          sequence_attributes[:alternate_values_attributes].push({
            type: 'AlternateValue::AlternateSpelling',
            alternate_value_object_attribute: 'name',
            value: alternate_name
          })
        end

        # DataAttributes attributes
        sequence_attributes[:data_attributes_attributes].push({
          type: 'ImportAttribute',
          import_predicate: 'GeneName',
          value: sequence_obj[:gene_name]
        })

        sequence_attributes[:data_attributes_attributes].push({
          type: 'ImportAttribute',
          import_predicate: 'Type',
          value: sequence_obj[:type]
        })

        parse_result = @processed_rows[sequence_obj[:index]]
        parse_result.objects[:sequence].push(Sequence.new(sequence_attributes))
      end
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
