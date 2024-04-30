module Queries
  module DataAttribute
    class Filter < Query::Filter

      include Concerns::Polymorphic
      polymorphic_klass(::DataAttribute)

      PARAMS = [
        *::DataAttribute.related_foreign_keys.map(&:to_sym),
        :value,
        :controlled_vocabulary_term_id,
        :import_predicate,
        :type,
        :attribute_subject_type,
        :attribute_subject_id,
        :data_attribute_id,
        controlled_vocabulary_term_id: [],
        data_attribute_id: []
      ].freeze

      # Params specific to DataAttribute
      attr_accessor :value

      # @return [Array]
      attr_accessor :controlled_vocabulary_term_id

      attr_accessor :import_predicate

      attr_accessor :type

      attr_accessor :attribute_subject_type

      attr_accessor :attribute_subject_id

      attr_accessor :data_attribute_id

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super

        @attribute_subject_id = params[:attribute_subject_id]
        @attribute_subject_type = params[:attribute_subject_type]
        @controlled_vocabulary_term_id = params[:controlled_vocabulary_term_id]
        @data_attribute_id = params[:data_attribute_id]
        @import_predicate = params[:import_predicate]
        @type = params[:type]
        @value = params[:value]

        set_polymorphic_params(params)
      end

      def data_attribute_id
        [@data_attribute_id].flatten.compact
      end

      def controlled_vocabulary_term_id
        [@controlled_vocabulary_term_id].flatten.compact
      end

      # TODO - rename matching to _facet

      # @return [Arel::Node, nil]
      def matching_attribute_subject_type
        attribute_subject_type.present? ? table[:attribute_subject_type].eq(attribute_subject_type)  : nil
      end

      # @return [Arel::Node, nil]
      def matching_attribute_subject_id
        attribute_subject_id.present? ? table[:attribute_subject_id].eq(attribute_subject_id)  : nil
      end

      # @return [Arel::Node, nil]
      def matching_value
        value.blank? ? nil : table[:value].eq(value)
      end

      # @return [Arel::Node, nil]
      def matching_import_predicate
        import_predicate.blank? ? nil : table[:import_predicate].eq(import_predicate)
      end

      # @return [Arel::Node, nil]
      def matching_type
        type.blank? ? nil : table[:type].eq(type)
      end

      # @return [Arel::Node, nil]
      def matching_controlled_vocabulary_term_id
        controlled_vocabulary_term_id.empty? ? nil : table[:controlled_vocabulary_term_id].in(controlled_vocabulary_term_id)
      end

      # Replaces things like `otu_query_facet)
      def from_filter_facet(query, project_ids = [])
        return nil if query.nil?
        t = "query_#{query.table.name}_da"
        
        k = query.referenced_klass.name

        q = query

        if !project_ids.empty?
          q = q.all.where(project_id: project_ids) 
        else
          q = q.all
        end

        s = "WITH #{t} AS (" + q.to_sql + ') ' +
          ::DataAttribute
          .joins("JOIN #{t} as #{t}1 on data_attributes.attribute_subject_id = #{t}1.id AND data_attributes.attribute_subject_type = '" + k + "'")
          .to_sql

        ::DataAttribute.from('(' + s + ') as data_attributes').distinct
      end

      def merge_clauses
        [
          from_filter_facet(otu_query, project_id),
          from_filter_facet(taxon_name_query, project_id),
          from_filter_facet(collecting_event_query, project_id),
          from_filter_facet(collection_object_query, project_id),
        ]
      end

      def and_clauses
        [
          matching_type,
          matching_value,
          matching_import_predicate,
          matching_attribute_subject_id,
          matching_attribute_subject_type,
          matching_controlled_vocabulary_term_id,
        ]
      end

    end
  end
end
