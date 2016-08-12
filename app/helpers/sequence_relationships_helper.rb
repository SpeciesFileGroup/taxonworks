module SequenceRelationshipsHelper
    def sequence_relationship_tag(sequence_relationship)
        return nil if sequence_relationship.nil?
        [sequence_relationship.subject_sequence.sequence, sequence_relationship.object_sequence.sequence].join(" : ")
    end

    def sequence_relationship_link(sequence_relationship)
        return nil if sequence_relationship.nil?
        link_to(sequence_relationship_tag(sequence_relationship).html_safe, sequence_relationship)
    end
end
