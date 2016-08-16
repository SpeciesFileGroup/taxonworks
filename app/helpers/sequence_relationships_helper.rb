module SequenceRelationshipsHelper
    def sequence_relationship_tag(sequence_relationship)
        return nil if sequence_relationship.nil?
        [sequence_relationship.subject_sequence_id, sequence_relationship.object_sequence_id].join(" : ")
    end

    def sequence_relationship_link(sequence_relationship)
        return nil if sequence_relationship.nil?
        link_to(sequence_relationship_tag(sequence_relationship.metamorphosize).html_safe, sequence_relationship.metamorphosize)
    end

    def sequence_relationship_type_select_options
        %w[ReversePrimer ForwardPrimer BlastQuerySequence ReferenceSequenceForAssembly]
    end

    def sequence_relationships_search_form
        render('/sequence_relationships/quick_search_form')
    end
end
