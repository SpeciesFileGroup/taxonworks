module Queries
  module Identifier

    # !! does not inherit from Queries::Query
    class Filter < Query::Filter

      include Concerns::Polymorphic
      polymorphic_klass(::Identifier)

      # A fully qualified identifier, matches cached
      # !! This is the only wildcarded value !!
      attr_accessor :query_string

      # @return [Array]
      attr_accessor :identifier

      # @return [Array]
      attr_accessor :namespace_id
      attr_accessor :namespace_short_name
      attr_accessor :namespace_name

      # @param identifier_object_type [Array, String]
      #   like 'Otu'
      #      or ['Otu', 'Specimen']
      attr_accessor :identifier_object_type

      attr_accessor :identifier_object_id

      attr_accessor :object_global_id

      # @return Array
      attr_accessor :type

      attr_accessor :project_id

      attr_accessor :options

      # @params params [ActionController::Parameters]
      def initialize(params)

        @options = params

        @identifier = params[:identifier]
        @identifier_object_id = params[:identifier_object_id]
        @identifier_object_type = params[:identifier_object_type]
        @namespace_id = params[:namespace_id]
        @namespace_name = params[:namespace_name]
        @namespace_short_name = params[:namespace_short_name]
        @project_id = params[:project_id]
        @query_string = params[:query_string]
        @type = params[:type]

        # See Queries::Concerns::Polymorphic
        @object_global_id = params[:object_global_id]
        set_polymorphic_ids(params)
      end

      def type
        [@type].flatten.compact.uniq
      end

      def namespace_id
        [@namespace_id].flatten.compact.uniq
      end

      def identifier
        [@identifier].flatten.compact.uniq
      end

      def identifier_object_type
        [@identifier_object_type, global_object_type].flatten.compact
      end

      def identifier_object_id
        [@identifier_object_id, global_object_id].flatten.compact
      end

      def annotated_class
        ::Queries::Annotator.annotated_class(options, ::Identifier)
      end

      def ignores_project?
        # Use the same constant - TODO: move it dual annotator likely
        ::Identifier::ALWAYS_COMMUNITY.include?( annotated_class )
      end

      # Ommits non community klasses of identifiers
      def community_project_id_facet
        return nil if project_id.nil?
          if !ignores_project?
            # Not a community class
            return table[:project_id].eq(project_id)
          else
            # Is a community class
            # Identifiers that are not local only
            return table[:type].matches('Identifier::Global%').or(table[:project_id].eq(project_id))
          end
        nil
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          Queries::Annotator.annotator_params(options, ::Identifier),
          matching_cached,
          matching_identifier_attribute(:identifier),
          matching_identifier_attribute(:namespace_id),
          matching_identifier_attribute(:type),
          matching_identifier_object_id,
          matching_identifier_object_type,
          matching_polymorphic_ids,

          community_project_id_facet,
        ].flatten.compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      def merge_clauses
        clauses = [
          matching_namespace(:short_name),
          matching_namespace(:name),
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      # @return [Arel::Node, nil]
      def matching_cached
        query_string.blank? ? nil : table[:cached].matches('%' + query_string + '%')
      end

      # @return [Arel::Node, nil]
      def matching_identifier_object_id
        identifier_object_id.empty? ? nil : table[:identifier_object_id].eq_any(identifier_object_id)
      end

      # @return [Arel::Node, nil]
      def matching_identifier_object_type
        identifier_object_type.empty? ? nil : table[:identifier_object_type].eq_any(identifier_object_type)
      end

      # @return [Arel::Node, nil]
      def matching_identifier_attribute(attribute)
        v = send(attribute)
        v.blank? ? nil : table[attribute].eq_any(v)
      end

      def matching_namespace(attribute)
        v = self.send("namespace_#{attribute}")
        return nil if v.blank?
        o = table
        n = ::Namespace.arel_table

        a = o.alias("a_")
        b = o.project(a[Arel.star]).from(a)

        c = n.alias('n1')

        b = b.join(c, Arel::Nodes::OuterJoin)
          .on(
            a[:namespace_id].eq(c[:id])
        )

        e = c[:id].not_eq(nil)
        f = c[attribute].eq(v)

        b = b.where(e.and(f))
        b = b.group(a['id'])
        b = b.as('z5_')

        ::Identifier.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = merge_clauses
        if a && b
          b.where(a).distinct
        elsif a
          ::Identifier.where(a).distinct
        elsif b
          b.distinct
        else
          ::Identifier.all
        end
      end
    end
  end
end
