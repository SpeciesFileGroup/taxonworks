module Queries
  module Citation

    class Filter < Query::Filter
      include Queries::Helpers

      include Concerns::Polymorphic
      polymorphic_klass(::Citation)

      include Queries::Concerns::Tags
      include Queries::Concerns::Notes
      include Queries::Concerns::Verifiers

      # Citation is an annotator (it annotates other objects), so the base
      # `included_annotator_facets` skips annotation concerns. Citation itself
      # can be tagged, noted, and verified — wire those concerns in explicitly
      # so the standard filter facets work. Citation cannot carry DataAttributes
      # or Confidences (no annotations on annotators).
      def self.included_annotator_facets
        super + [
          ::Queries::Concerns::Tags,
          ::Queries::Concerns::Notes,
          ::Queries::Concerns::Verifiers
        ]
      end

      PARAMS = [
        *::Citation.related_foreign_keys.map(&:to_sym),
        :citation_id,
        :citation_object_id,
        :citation_object_type,
        :source_id,
        :is_original,
        :topic_id,
        :citation_topics,
        :citation_topic_pages,
        :citation_topic_pages_exact,
        :source_documents,
        role_id: [],
        citation_object_id: [],
        citation_object_type: [],
        topic_id: [],
      ].freeze

      # Array, Integer
      attr_accessor :citation_object_type

      attr_accessor :citation_object_id

      attr_accessor :source_id

      # Boolean
      attr_accessor :is_original

      # Array of Topic ids — matches Citations that have a CitationTopic to any of these.
      attr_accessor :topic_id

      # Boolean — true: only Citations with any CitationTopic; false: only those
      # without; nil: no constraint.
      attr_accessor :citation_topics

      # String — match against citation_topics.pages (ILIKE wildcard by
      # default, exact match when `citation_topic_pages_exact` is true).
      # Useful when CitationTopic carries its own per-topic page range
      # (e.g. ScaleNet's imported keys with kypage on the topic, not the
      # citation).
      attr_accessor :citation_topic_pages

      attr_accessor :citation_topic_pages_exact

      # Boolean — true: only Citations whose Source has any documentation in
      # the current project; false: only those whose Source has none.
      attr_accessor :source_documents

      # @return [Queries::Source::Filter, nil]
      # Citation has a direct source_id FK, so Source acts as a sender in
      # the radial filter chain. The base Query::Filter does not declare
      # this accessor (it's provided to other filters via
      # Queries::Concerns::Citations, which Citation itself cannot include).
      attr_accessor :source_query

      # @params params [Hash]
      #   already Permitted params, or new Hash
      def initialize(query_params)
        super

        @citation_id = params[:citation_id]
        @citation_object_id = params[:citation_object_id]
        @citation_object_type = params[:citation_object_type]
        @is_original = params[:is_original]
        @source_id = params[:source_id]
        @topic_id = params[:topic_id]
        @citation_topics = boolean_param(params, :citation_topics)
        @citation_topic_pages = params[:citation_topic_pages]
        @citation_topic_pages_exact = boolean_param(params, :citation_topic_pages_exact)
        @source_documents = boolean_param(params, :source_documents)

        set_polymorphic_params(params)
        set_tags_params(params)
        set_notes_params(params)
        set_verifiers_params(params)
      end

      def citation_object_type
        [@citation_object_type].flatten.compact
      end

      def citation_object_id
        [@citation_object_id].flatten.compact
      end

      def source_id
        [@source_id].flatten.compact
      end

      def citation_id
        [@citation_id].flatten.compact
      end

      def topic_id
        [@topic_id].flatten.compact
      end

      def citation_object_type_facet
        return nil if citation_object_type.empty?
        table[:citation_object_type].in(citation_object_type)
      end

      def citation_object_id_facet
        return nil if citation_object_id.empty?
        table[:citation_object_id].in(citation_object_id)
      end

      def source_id_facet
        return nil if source_id.empty?
        table[:source_id].in(source_id)
      end

      def is_original_facet
        is_original.blank? ? nil : table[:is_original].eq(is_original)
      end

      def topic_id_facet
        return nil if topic_id.empty?
        ::Citation.joins(:citation_topics).where(citation_topics: { topic_id: }).distinct
      end

      def citation_topics_facet
        return nil if citation_topics.nil?
        if citation_topics
          ::Citation.joins(:citation_topics).distinct
        else
          ::Citation.where.missing(:citation_topics)
        end
      end

      def citation_topic_pages_facet
        return nil if citation_topic_pages.blank?
        predicate = if citation_topic_pages_exact
          ::CitationTopic.arel_table[:pages].eq(citation_topic_pages)
        else
          ::CitationTopic.arel_table[:pages].matches("%#{citation_topic_pages}%")
        end
        ::Citation.joins(:citation_topics).where(predicate).distinct
      end

      def source_documents_facet
        return nil if source_documents.nil?
        sources_with_docs = ::Source
          .joins(:documentation)
          .where(documentation: { project_id: })
          .distinct
        if source_documents
          ::Citation.where(source_id: sources_with_docs.select(:id))
        else
          ::Citation.where.not(source_id: sources_with_docs.select(:id))
        end
      end

      def and_clauses
        [
          citation_object_type_facet,
          citation_object_id_facet,
          source_id_facet,
          is_original_facet
        ]
      end

      # Helper for facets that match citations whose polymorphic
      # citation_object resolves to a model in a nested subquery.
      def citation_object_query_facet(query, klass_name, cte_name)
        return nil if query.nil?
        ::Citation
          .with(cte_name.to_sym => query.all)
          .joins("JOIN #{cte_name} ON #{cte_name}.id = citations.citation_object_id AND citations.citation_object_type = '#{klass_name}'")
          .distinct
      end

      def anatomical_part_query_facet
        citation_object_query_facet(anatomical_part_query, 'AnatomicalPart', 'query_ap_c')
      end

      def asserted_distribution_query_facet
        citation_object_query_facet(asserted_distribution_query, 'AssertedDistribution', 'query_ad_c')
      end

      def biological_association_query_facet
        citation_object_query_facet(biological_association_query, 'BiologicalAssociation', 'query_ba_c')
      end

      def collecting_event_query_facet
        citation_object_query_facet(collecting_event_query, 'CollectingEvent', 'query_ce_c')
      end

      def collection_object_query_facet
        citation_object_query_facet(collection_object_query, 'CollectionObject', 'query_co_c')
      end

      def content_query_facet
        citation_object_query_facet(content_query, 'Content', 'query_cnt_c')
      end

      def descriptor_query_facet
        citation_object_query_facet(descriptor_query, 'Descriptor', 'query_d_c')
      end

      def extract_query_facet
        citation_object_query_facet(extract_query, 'Extract', 'query_ex_c')
      end

      def field_occurrence_query_facet
        citation_object_query_facet(field_occurrence_query, 'FieldOccurrence', 'query_fo_c')
      end

      def image_query_facet
        citation_object_query_facet(image_query, 'Image', 'query_im_c')
      end

      def observation_query_facet
        citation_object_query_facet(observation_query, 'Observation', 'query_obs_c')
      end

      def otu_query_facet
        citation_object_query_facet(otu_query, 'Otu', 'query_otu_c')
      end

      def sound_query_facet
        citation_object_query_facet(sound_query, 'Sound', 'query_snd_c')
      end

      def taxon_name_query_facet
        citation_object_query_facet(taxon_name_query, 'TaxonName', 'query_tn_c')
      end

      def taxon_name_relationship_query_facet
        citation_object_query_facet(taxon_name_relationship_query, 'TaxonNameRelationship', 'query_tnr_c')
      end

      # Source has a direct FK (citations.source_id), not a polymorphic join.
      def source_query_facet
        return nil if source_query.nil?
        ::Citation
          .with(query_src_c: source_query.all)
          .joins('JOIN query_src_c ON query_src_c.id = citations.source_id')
          .distinct
      end

      def merge_clauses
        [
          topic_id_facet,
          citation_topics_facet,
          citation_topic_pages_facet,
          source_documents_facet,
          anatomical_part_query_facet,
          asserted_distribution_query_facet,
          biological_association_query_facet,
          collecting_event_query_facet,
          collection_object_query_facet,
          content_query_facet,
          descriptor_query_facet,
          extract_query_facet,
          field_occurrence_query_facet,
          image_query_facet,
          observation_query_facet,
          otu_query_facet,
          sound_query_facet,
          source_query_facet,
          taxon_name_query_facet,
          taxon_name_relationship_query_facet
        ]
      end

    end
  end
end
