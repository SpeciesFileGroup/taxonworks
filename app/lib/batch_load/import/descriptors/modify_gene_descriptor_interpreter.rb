module BatchLoad
  class Import::Descriptors::ModifyGeneDescriptorInterpreter < BatchLoad::Import

    # @param [Hash] args
    def initialize(**args)
      @descriptors = {}
      super(**args)
    end

    # @return [Integer]
    def build_descriptors
      @total_data_lines = 0
      i = 0

      # loop through rows
      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:descriptor] = []

        @processed_rows[i] = parse_result

        begin # processing
          # Find gene descriptor
          gene_name = row['gene_name']
          gene_descriptor = Descriptor::Gene.find_by(name: gene_name)
          next if gene_descriptor.blank?

          # Store gene attribute logic for each primer
          primers_logic = { "forward_primers": [], "reverse_primers": [] }

          # Find each forward/reverse primers and store their gene attribute logic
          ['forward_primers', 'reverse_primers'].each do |primer_type|
            primers = row[primer_type]
            next if primers.blank?
            sequence_relationship_type = 'SequenceRelationship::' + primer_type.singularize.camelize

            primers.split(', ').each do |primer_name|
              primer_sequence = Sequence.with_any_value_for(:name, primer_name).take
              next if primer_sequence.blank?

              gene_attribute = GeneAttribute.find_by(descriptor: gene_descriptor, sequence: primer_sequence, sequence_relationship_type: sequence_relationship_type)
              next if gene_attribute.blank?

              primers_logic[primer_type.to_sym].push(gene_attribute.to_logic_literal)
            end
          end

          gene_descriptor_logic = ''
          gene_descriptor_logic += '(' + primers_logic[:forward_primers].join(' OR ') + ')'
          gene_descriptor_logic += ' AND '
          gene_descriptor_logic += '(' + primers_logic[:reverse_primers].join(' OR ') + ')'
          gene_descriptor.gene_attribute_logic = gene_descriptor_logic
          parse_result.objects[:descriptor].push(gene_descriptor)
          @total_data_lines += 1
        # rescue
        end
      end


      @total_lines = i
    end

    # @return [Boolean]
    def build
      if valid?
        build_descriptors
        @processed = true
      end
    end
  end
end
