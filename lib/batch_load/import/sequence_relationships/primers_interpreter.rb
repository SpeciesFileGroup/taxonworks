module BatchLoad
  class Import::SequenceRelationships::PrimersInterpreter < BatchLoad::Import

    def initialize(**args)
      @sequence_relationships = {}
      super(args)
    end

    def build_sequence_relationships
      @total_data_lines = 0
      i = 0
      gene_descriptors = {}
      gene_attributes = {}

      # loop throw rows
      csv.each do |row|
        i += 1

        parse_result = BatchLoad::RowParse.new
        parse_result.objects[:sequence_relationship] = []
        parse_result.objects[:gene_descriptor] = []
        parse_result.objects[:gene_attribute] = []

        @processed_rows[i] = parse_result

        begin # processing
          # gene descriptor
          gene_name = row["gene_name"]
          gene_descriptor = gene_descriptors[gene_name]

          if !gene_descriptor
            gene_descriptor = Descriptor::Gene.new(name: gene_name)
            gene_descriptors[gene_name] = gene_descriptor
            parse_result.objects[:gene_descriptor].push(gene_descriptor)
          end

          # sequence relationships/gene attributes
          sequence_id = row["identifier"]
          sequence = Sequence.with_namespaced_identifier("DRMSequenceId", sequence_id).take
          created_sequence_relationship = false
          
          if sequence
            ["ForwardPrimer", "ReversePrimer"].each do |primer_type|
              sequence_relationship_type = "SequenceRelationship::" + primer_type
              primer_type_key = primer_type.underscore + "s"
              primers = row[primer_type_key]
              next if primers.blank?

              primers.split(", ").each do |primer|
                primer_sequence = Sequence.with_any_value_for(:name, primer).take

                if primer_sequence
                  sequence_relationship_type = get_relationship_type(primer_sequence)
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
            end

            if created_sequence_relationship
              @total_data_lines += 1
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
  end
end
