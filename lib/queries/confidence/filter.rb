module Queries
  module Confidence
    class Filter < Query::Filter
      include Concerns::Polymorphic
      polymorphic_klass(::Confidence)

      PARAMS = [
        *::Confidence.related_foreign_keys.map(&:to_sym),
        :confidence_id,
        :confidence_level_id,
        :confidence_object_id,
        :confidence_object_type,
        confidence_id: [],
        confidence_level_id: [],
        confidence_object_type: [],
      ].freeze

      # @return Array
      attr_accessor :confidence_id

      # @return Array
      attr_accessor :confidence_level_id

      # @return Array
      attr_accessor :confidence_object_type

      # @return Array
      attr_accessor :confidence_object_id

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super
        @confidence_id = params[:confidence_id]
        @confidence_level_id = [params[:confidence_level_id]].flatten.compact
        @confidence_object_type = params[:confidence_object_type]
        @confidence_object_id = params[:confidence_object_id]

        set_polymorphic_params(params)
      end

      def confidence_id
        [@confidence_id].flatten.compact.uniq
      end

      def confidence_object_type
        [@confidence_object_type].flatten.compact
      end

      def confidence_object_id
        [@confidence_object_id].flatten.compact
      end

      # @return [Arel::Node, nil]
      def confidence_level_id_facet
        confidence_level_id.present? ? table[:confidence_level_id].in(confidence_level_id)  : nil
      end

      # @return [Arel::Node, nil]
      def confidence_object_type_facet
        confidence_object_type.present? ? table[:confidence_object_type].in(confidence_object_type)  : nil
      end

      # @return [Arel::Node, nil]
      def confidence_object_id_facet
        confidence_object_id.empty? ? nil : table[:confidence_object_id].in(confidence_object_id)
      end

      def and_clauses
        [
          confidence_level_id_facet,
          confidence_object_id_facet,
          confidence_object_type_facet,
        ]
      end

      def anatomical_part_query_facet
        polymorphic_annotation_object_query_facet(anatomical_part_query, 'AnatomicalPart', 'query_ap_cf')
      end

      def asserted_distribution_query_facet
        polymorphic_annotation_object_query_facet(asserted_distribution_query, 'AssertedDistribution', 'query_ad_cf')
      end

      def biological_association_query_facet
        polymorphic_annotation_object_query_facet(biological_association_query, 'BiologicalAssociation', 'query_ba_cf')
      end

      def collecting_event_query_facet
        polymorphic_annotation_object_query_facet(collecting_event_query, 'CollectingEvent', 'query_ce_cf')
      end

      def collection_object_query_facet
        polymorphic_annotation_object_query_facet(collection_object_query, 'CollectionObject', 'query_co_cf')
      end

      def content_query_facet
        polymorphic_annotation_object_query_facet(content_query, 'Content', 'query_cnt_cf')
      end

      def descriptor_query_facet
        polymorphic_annotation_object_query_facet(descriptor_query, 'Descriptor', 'query_d_cf')
      end

      def extract_query_facet
        polymorphic_annotation_object_query_facet(extract_query, 'Extract', 'query_ex_cf')
      end

      def field_occurrence_query_facet
        polymorphic_annotation_object_query_facet(field_occurrence_query, 'FieldOccurrence', 'query_fo_cf')
      end

      def observation_query_facet
        polymorphic_annotation_object_query_facet(observation_query, 'Observation', 'query_obs_cf')
      end

      def otu_query_facet
        polymorphic_annotation_object_query_facet(otu_query, 'Otu', 'query_otu_cf')
      end

      def sound_query_facet
        polymorphic_annotation_object_query_facet(sound_query, 'Sound', 'query_snd_cf')
      end

      def taxon_name_query_facet
        polymorphic_annotation_object_query_facet(taxon_name_query, 'TaxonName', 'query_tn_cf')
      end

      def merge_clauses
        [
          anatomical_part_query_facet,
          asserted_distribution_query_facet,
          biological_association_query_facet,
          collecting_event_query_facet,
          collection_object_query_facet,
          content_query_facet,
          descriptor_query_facet,
          extract_query_facet,
          field_occurrence_query_facet,
          observation_query_facet,
          otu_query_facet,
          sound_query_facet,
          taxon_name_query_facet
        ]
      end

    end
  end
end
