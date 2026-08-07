module BatchLoad
  module Helpers::Sequences
    # @param [String] filename
    # @param [String] file_content
    # @return [Sequence]
    def create_sequence(filename, file_content)
      # DRMSequenceId DRMSEQID
      namespace_sequence_id = Namespace.find_by(name: 'DRMSequenceId')

      # Sequence attributes
      sequence_attributes = {
        name: get_taxon_name(filename) + '_' + get_voucher_number(filename) + '_' + get_gene_fragement(filename),
        sequence_type: get_sequence_type(filename),
        sequence: get_sequence(file_content),
        identifiers_attributes: []
      }

      # Identifiers for Sequence
      sequence_identifier_genbank_text = get_genbank_text(filename)
      sequence_identifier_genbank = {
        type: 'Identifier::Global::GenBankAccessionCode',
        identifier: sequence_identifier_genbank_text
      }

      sequence_identifier_sequence_id_text = get_sequence_id_text(filename)
      sequence_identifier_sequence_id = {
        namespace: namespace_sequence_id,
        type: 'Identifier::Local::Import',
        identifier: sequence_identifier_sequence_id_text
      }

      sequence_attributes[:identifiers_attributes].push(sequence_identifier_genbank) if sequence_identifier_genbank_text.present?
      sequence_attributes[:identifiers_attributes].push(sequence_identifier_sequence_id) if sequence_identifier_sequence_id_text.present?

      sequence = Sequence.new(sequence_attributes)
      sequence
    end

    # @param [String] filename
    # @param [Sequence] sequence
    # @return [OriginRelationship]
    def create_origin_relationship(filename, sequence)
      # Extract that this sequence came from
      extract = Extract.with_namespaced_identifier('GenBank', get_voucher_number(filename)).take

      # OriginRelationship for Extract(source) and Sequence(target)
      origin_relationship = nil

      if extract.present?
        origin_relationship_attributes = { old_object: extract, new_object: sequence }
        origin_relationship = OriginRelationship.new(origin_relationship_attributes)
      end

      origin_relationship
    end

    # @param [String] filename
    # @return [String]
    def get_genbank_text(filename)
      # _&aKJ624355_&
      return get_between_strings(filename, '_&a', '_&')
    end

    # @param [String] filename
    # @return [String]
    def get_sequence_id_text(filename)
      # &iSEQID00000349_&
      return get_between_strings(filename, '&i', '_&')
    end

    # @param [String] file_content
    # @return [String]
    def get_sequence(file_content)
      new_line_index = file_content.index("\n") # Double quotes are needed to properly interpret new line character
      new_line_index ||= 0
      file_content[(new_line_index + 1)...(file_content.length - 1)]
    end

    # @param [String] filename
    # @return [String]
    def get_sequence_type(filename)
      'DNA'
    end

    # @param [String] filename
    # @return [String]
    def get_voucher_number(filename)
      # &vDRMDNA2303_&
      return get_between_strings(filename, '&vDRM', '_&')
    end

    # @param [String] filename
    # @return [String]
    def get_gene_fragement(filename)
      # _&fCOIBC_& or _&gCOIBC_&
      f_fragement = get_between_strings(filename, '_&f', '_&')
      return f_fragement.presence || get_between_strings(filename, '_&g', '_&')
    end

    # @param [String] filename
    # @return [String]
    def get_taxon_name(filename)
      # Identifier to find collection object
      voucher_number = get_voucher_number(filename)
      identifier_text = voucher_number

      collection_object = CollectionObject.with_namespaced_identifier('DRMDNA', identifier_text).take

      # Taxon determination associated with collection object
      if collection_object
        taxon_determination = TaxonDetermination.find_by(taxon_determination_object: collection_object)

        if taxon_determination
          otu = taxon_determination.otu
          taxon_name = otu.taxon_name
          return taxon_name.name
        end
      end

      ''
    end

    # @param [String] str
    # @param [String] beg_marker
    # @param [String] end_marker
    # @return [String]
    def get_between_strings(str, beg_marker, end_marker)
      beg_marker_index = str.index(beg_marker)

      if beg_marker_index
        beg_marker_index += beg_marker.length
        end_marker_index = str.index(end_marker, beg_marker_index)
        return str[beg_marker_index...end_marker_index] if end_marker_index
      end

      ''
    end
  end
end
