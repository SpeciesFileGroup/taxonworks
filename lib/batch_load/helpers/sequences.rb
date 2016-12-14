module BatchLoad
  module Helpers::Sequences
    def create_sequence(filename, file_content)
      # GenBank GBK
      namespace_genbank = Namespace.find_by(name: 'GenBank')

      # Sequence attributes
      sequence_attributes = { name: nil, sequence_type: nil, sequence: nil, identifiers_attributes: [] }

      sequence_attributes[:name] = get_taxon_name(filename) + "_" + get_voucher_number(filename) + "_" + get_gene_fragement(filename)
      sequence_attributes[:sequence_type] = get_sequence_type(filename)
      sequence_attributes[:sequence] = get_sequence(file_content)

      # Identifiers for Sequence
      sequence_identifier_genbank_text = get_genbank_text(filename)
      

      sequence_identifier_genbank = { namespace: namespace_genbank,
                                      type: 'Identifier::Local::Sequence',
                                      identifier: sequence_identifier_genbank_text }

      sequence_attributes[:identifiers_attributes].push(sequence_identifier_genbank) if !sequence_identifier_genbank_text.blank?
      sequence = Sequence.new(sequence_attributes)
      sequence
    end

    def create_origin_relationship(filename, sequence)
      # Extract that this sequence came from
      extracts = Extract.with_namespaced_identifier('GenBank', get_voucher_number(filename))  
      extract = nil
      extract = extracts.first if extracts.any?

      # OriginRelationship for Extract(source) and Sequence(target)
      origin_relationship = nil
      
      if !extract.nil?
        origin_relationship_attributes = { old_object: extract, new_object: sequence }
        origin_relationship = OriginRelationship.new(origin_relationship_attributes)
      end

      origin_relationship
    end

    def get_genbank_text(filename)
      # _&aKJ624355_&
      return get_between_strings(filename, "_&a", "_&")
    end

    def get_sequence(file_content)
      new_line_index = file_content.index("\n") # Double quotes are needed to properly interpret new line character
      new_line_index ||= 0
      file_content[(new_line_index + 1)...(file_content.length - 1)]
    end

    def get_sequence_type(filename)
      "DNA"
    end

    def get_voucher_number(filename)
      # &vDRMDNA2303_&
      return get_between_strings(filename, "&vDRM", "_&")
    end

    def get_gene_fragement(filename)
      # _&fCOIBC_& or _&gCOIBC_&
      f_fragement = get_between_strings(filename, "_&f", "_&")
      return f_fragement.blank? ? get_between_strings(filename, "_&g", "_&") : f_fragement
    end

    def get_taxon_name(filename)
      # Identifier to find collection object
      voucher_number = get_voucher_number(filename)
      identifier_text = voucher_number

      collection_objects = CollectionObject.with_namespaced_identifier("DRMDNA", identifier_text)
      collection_object = nil
      collection_object = collection_objects.first if collection_objects.any?

      # Taxon determination associated with collection object
      if collection_object
        taxon_determinations = TaxonDetermination.where(biological_collection_object_id: collection_object.id)
        taxon_determination = nil
        taxon_determination = taxon_determinations.first if taxon_determinations.any?

        if taxon_determination
          otu = taxon_determination.otu
          taxon_name = otu.taxon_name
          return taxon_name.name
        end
      end

      ""
    end

    def get_between_strings(str, beg_marker, end_marker)
      beg_marker_index = str.index(beg_marker)

      if beg_marker_index
        beg_marker_index += beg_marker.length
        end_marker_index = str.index(end_marker, beg_marker_index)
        return str[beg_marker_index...end_marker_index] if end_marker_index
      end

      ""
    end
  end
end