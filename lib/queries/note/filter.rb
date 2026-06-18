module Queries
  module Note
    class Filter < Query::Filter

      include Concerns::Polymorphic
      polymorphic_klass(::Note)

      PARAMS = [
        *::Note.related_foreign_keys.map(&:to_sym),
        :note_id,
        :text,
        :note_object_type,
        :note_object_id,
        note_id: [],
        note_object_id: [],
        note_object_type: [],
      ].freeze

      # @return Array
      attr_accessor :note_id

      # @param text [String, nil]
      #   wildcard wrapped, always, to match against `text`
      attr_accessor :text

      # @return [Array]
      # @params note_object_type array or string
      attr_accessor :note_object_type

      # @return [Array]
      # @params note_object_id array or string (integer)
      attr_accessor :note_object_id

      def initialize(query_params)
        super

        @note_id = params[:note_id]
        @text = params[:text]
        @note_object_type = params[:note_object_type]
        @note_object_id = params[:note_object_id]

        set_polymorphic_params(params)
      end

      def note_id
        [@note_id].flatten.compact
      end

      def note_object_id
        [@note_object_id].flatten.compact
      end

      def note_object_type
        [@note_object_type].flatten.compact
      end

      def text_facet
        return nil if text.blank?
        table[:text].matches('%' + text + '%')
      end

      def note_object_type_facet
        return nil if note_object_type.empty?
        table[:note_object_type].in(note_object_type)
      end

      def note_object_id_facet
        return nil if note_object_id.empty?
        table[:note_object_id].in(note_object_id)
      end

      def and_clauses
        [
          text_facet,
          note_object_id_facet,
          note_object_type_facet,
        ]
      end

      def anatomical_part_query_facet
        polymorphic_annotation_object_query_facet(anatomical_part_query, 'AnatomicalPart', 'query_ap_n')
      end

      def asserted_distribution_query_facet
        polymorphic_annotation_object_query_facet(asserted_distribution_query, 'AssertedDistribution', 'query_ad_n')
      end

      def biological_association_query_facet
        polymorphic_annotation_object_query_facet(biological_association_query, 'BiologicalAssociation', 'query_ba_n')
      end

      def collecting_event_query_facet
        polymorphic_annotation_object_query_facet(collecting_event_query, 'CollectingEvent', 'query_ce_n')
      end

      def collection_object_query_facet
        polymorphic_annotation_object_query_facet(collection_object_query, 'CollectionObject', 'query_co_n')
      end

      def descriptor_query_facet
        polymorphic_annotation_object_query_facet(descriptor_query, 'Descriptor', 'query_d_n')
      end

      def field_occurrence_query_facet
        polymorphic_annotation_object_query_facet(field_occurrence_query, 'FieldOccurrence', 'query_fo_n')
      end

      def image_query_facet
        polymorphic_annotation_object_query_facet(image_query, 'Image', 'query_im_n')
      end

      def observation_query_facet
        polymorphic_annotation_object_query_facet(observation_query, 'Observation', 'query_obs_n')
      end

      def otu_query_facet
        polymorphic_annotation_object_query_facet(otu_query, 'Otu', 'query_otu_n')
      end

      def sound_query_facet
        polymorphic_annotation_object_query_facet(sound_query, 'Sound', 'query_snd_n')
      end

      def taxon_name_query_facet
        polymorphic_annotation_object_query_facet(taxon_name_query, 'TaxonName', 'query_tn_n')
      end

      def taxon_name_relationship_query_facet
        polymorphic_annotation_object_query_facet(taxon_name_relationship_query, 'TaxonNameRelationship', 'query_tnr_n')
      end

      def merge_clauses
        [
          anatomical_part_query_facet,
          asserted_distribution_query_facet,
          biological_association_query_facet,
          collecting_event_query_facet,
          collection_object_query_facet,
          descriptor_query_facet,
          field_occurrence_query_facet,
          image_query_facet,
          observation_query_facet,
          otu_query_facet,
          sound_query_facet,
          taxon_name_query_facet,
          taxon_name_relationship_query_facet
        ]
      end
    end
  end
end
