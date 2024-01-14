module BatchLoad
  class Import::SequenceRelationships::PrimersInterpreter < BatchLoad::Import

    # @param [Hash] args
    def initialize(**args)
      @sequence_relationships = {}
      super(**args)
    end

    # @return [Integer]
    def build_sequence_relationships
      @total_data_lines = 0
      i = 0
      gene_descriptors = {}
      gene_attributes = {}

      # loop through rows
      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:sequence_relationship] = []
        parse_result.objects[:gene_descriptor] = []
        parse_result.objects[:gene_attribute] = []

        @processed_rows[i] = parse_result

        begin # processing
          # gene descriptor
          gene_name = row['gene_name']
          gene_descriptor = gene_descriptors[gene_name]

          if !gene_descriptor
            gene_descriptor = Descriptor::Gene.new(name: gene_name)
            gene_descriptors[gene_name] = gene_descriptor
            parse_result.objects[:gene_descriptor].push(gene_descriptor)
          end

          # sequence relationships/gene attributes
          sequence_id = row['identifier']
          sequence = Sequence.with_namespaced_identifier('DRMSequenceId', sequence_id).take
          next if sequence.blank?
          created_sequence_relationship = false

          ['forward_primers', 'reverse_primers'].each do |primer_type|
            primers = row[primer_type]
            next if primers.blank?
            sequence_relationship_type = 'SequenceRelationship::' + primer_type.singularize.camelize

            primers.split(', ').each do |primer_name|
              primer_sequence = Sequence.with_any_value_for(:name, primer_name).take
              next if primer_sequence.blank?

              sequence_relationship = SequenceRelationship.new({
                subject_sequence: primer_sequence,
                object_sequence: sequence,
                type: sequence_relationship_type
              })

              parse_result.objects[:sequence_relationship].push(sequence_relationship)
              created_sequence_relationship = true

              gene_attribute_props = {
                descriptor: gene_descriptor,
                sequence: primer_sequence,
                sequence_relationship_type: sequence_relationship_type
              }

              if !gene_attributes.key?(gene_attribute_props)
                gene_attributes[gene_attribute_props] = true
                parse_result.objects[:gene_attribute].push(GeneAttribute.new(gene_attribute_props))
              end
            end
          end

          if created_sequence_relationship
            @total_data_lines += 1
          end
        # rescue
        end
      end

      @total_lines = i
    end

    # @return [Boolean]
    def build
      if valid?
        build_sequence_relationships
        @processed = true
      end
    end
  end
end
