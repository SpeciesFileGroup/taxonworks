# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::Sequences::GenbankInterpreter < BatchLoad::Import

    def initialize(**args)
      @sequences = {}
      super(args)
    end

    # TODO: update this
    def build_sequences
      # GenBank GBK
      namespace_genbank = Namespace.find_by(name: 'GenBank')

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

          # Identifiers for Sequence
          sequence_identifier_genbank_text = row['genbank_accession']
          

          sequence_identifier_genbank = { namespace: namespace_genbank,
                                        type: 'Identifier::Local::Sequence',
                                        identifier: sequence_identifier_genbank_text }

          # Sequence
          sequence_attributes = { name: row['name'], sequence_type: row['sequence_type'], sequence: row['sequence'], identifiers_attributes: [] }
          sequence_attributes[:identifiers_attributes].push(sequence_identifier_genbank) if !sequence_identifier_genbank_text.blank?
          sequence = Sequence.new(sequence_attributes)

          parse_result.objects[:sequence].push(sequence)

          # Extract that this sequence came from
          extracts = Extract.with_namespaced_identifier('GenBank', row['voucher_number'])  
          extract = nil
          extract = extracts.first if extracts.any?
          
          # OriginRelationship for Extract(source) and Sequence(target)
          if !extract.nil?
            origin_relationship_attributes = { old_object: extract, new_object: sequence }
            origin_relationship = OriginRelationship.new(origin_relationship_attributes)
            ap origin_relationship
            ap origin_relationship.valid?
            parse_result.objects[:origin_relationship].push(origin_relationship)
          end

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
