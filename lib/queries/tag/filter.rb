module Queries
  module Tag

    class Filter < Query::Filter

      include Concerns::Polymorphic
      polymorphic_klass(::Tag)

      PARAMS = [
        *::Tag.related_foreign_keys.map(&:to_sym),
        :keyword_id,
        :tag_object_type,
        :tag_object_id,
        keyword_id: [],
        tag_object_type: [],
        tag_object_id: [],
      ].freeze

      # @return Array
      attr_accessor :tag_id

      # Array, Integer
      attr_accessor :keyword_id

      # Array, Integer
      attr_accessor :tag_object_type

      # Array, Integer
      attr_accessor :tag_object_id

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super

        @tag_id = params[:tag_id]
        @keyword_id = [params[:keyword_id]]
        @tag_object_type = params[:tag_object_type]
        @tag_object_id = params[:tag_object_id]

        set_polymorphic_params(params)
      end

      def tag_id
        [@tag_id].flatten.compact.uniq
      end

      def keyword_id
        [@keyword_id].flatten.compact.uniq
      end

      def tag_object_type
        [@tag_object_type].flatten.compact
      end

      def tag_object_id
        [@tag_object_id].flatten.compact
      end

      def keyword_id_facet
        !keyword_id.empty? ? table[:keyword_id].in(keyword_id)  : nil
      end

      def object_id_facet
        tag_object_id.empty? ? nil : table[:tag_object_id].in(tag_object_id)
      end

      def tag_object_type_facet
        tag_object_type.empty? ? nil : table[:tag_object_type].in(tag_object_type)
      end

      def and_clauses
        [
          keyword_id_facet,
          object_id_facet,
          tag_object_type_facet,
        ]
      end

      def anatomical_part_query_facet
        polymorphic_annotation_object_query_facet(anatomical_part_query, 'AnatomicalPart', 'query_ap_t')
      end

      def asserted_distribution_query_facet
        polymorphic_annotation_object_query_facet(asserted_distribution_query, 'AssertedDistribution', 'query_ad_t')
      end

      def biological_association_query_facet
        polymorphic_annotation_object_query_facet(biological_association_query, 'BiologicalAssociation', 'query_ba_t')
      end

      def collecting_event_query_facet
        polymorphic_annotation_object_query_facet(collecting_event_query, 'CollectingEvent', 'query_ce_t')
      end

      def collection_object_query_facet
        polymorphic_annotation_object_query_facet(collection_object_query, 'CollectionObject', 'query_co_t')
      end

      def descriptor_query_facet
        polymorphic_annotation_object_query_facet(descriptor_query, 'Descriptor', 'query_d_t')
      end

      def extract_query_facet
        polymorphic_annotation_object_query_facet(extract_query, 'Extract', 'query_ex_t')
      end

      def field_occurrence_query_facet
        polymorphic_annotation_object_query_facet(field_occurrence_query, 'FieldOccurrence', 'query_fo_t')
      end

      def image_query_facet
        polymorphic_annotation_object_query_facet(image_query, 'Image', 'query_im_t')
      end

      def observation_query_facet
        polymorphic_annotation_object_query_facet(observation_query, 'Observation', 'query_obs_t')
      end

      def otu_query_facet
        polymorphic_annotation_object_query_facet(otu_query, 'Otu', 'query_otu_t')
      end

      def sound_query_facet
        polymorphic_annotation_object_query_facet(sound_query, 'Sound', 'query_snd_t')
      end

      def taxon_name_query_facet
        polymorphic_annotation_object_query_facet(taxon_name_query, 'TaxonName', 'query_tn_t')
      end

      def merge_clauses
        [
          anatomical_part_query_facet,
          asserted_distribution_query_facet,
          biological_association_query_facet,
          collecting_event_query_facet,
          collection_object_query_facet,
          descriptor_query_facet,
          extract_query_facet,
          field_occurrence_query_facet,
          image_query_facet,
          observation_query_facet,
          otu_query_facet,
          sound_query_facet,
          taxon_name_query_facet
        ]
      end

    end
  end
end
