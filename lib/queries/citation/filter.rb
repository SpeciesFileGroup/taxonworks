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

      def merge_clauses
        [
          topic_id_facet,
          citation_topics_facet,
          citation_topic_pages_facet,
          source_documents_facet
        ]
      end

    end
  end
end
