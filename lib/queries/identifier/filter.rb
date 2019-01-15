module Queries
  module Identifier

    # !! does not inherit from Queries::Query
    class Filter

      include Concerns::Polymorphic
      polymorphic_klass(::Identifier)

      # A fully qualified identifier, matches cached
      attr_accessor :query_string

      attr_accessor :identifier

      attr_accessor :namespace_id
      attr_accessor :namespace_short_name
      attr_accessor :namespace_name

      attr_accessor :identifier_object_type, :identifier_object_id 
      attr_accessor :identifier_object_ids

      attr_accessor :type

      # TODO -> attribute does nothing yet
      # Probably turn it into component parts
      attr_accessor :object_global_id

      # @params params [ActionController::Parameters]
      def initialize(params)
        @query_string = params[:query_string]
        @namespace_id = params[:namespace_id]
        @identifier = params[:identifier]
        @namespace_short_name = params[:namespace_short_name]
        @namespace_name = params[:namespace_name]

        @identifier_object_type = params[:identifier_object_type] 
        @identifier_object_id = params[:identifier_object_id] 

        @identifier_object_ids = params[:identifier_object_id] || []

        @type = params[:type]

        self.object_global_id = params[:object_global_id]

        set_polymorphic_ids(params)
        # need 'set annotator params'
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          # Queries::Annotator.annotator_params(options, ::Identifier),
          matching_cached,
          matching_identifier_attribute(:identifier),
          matching_identifier_attribute(:namespace_id),
          matching_identifier_attribute(:identifier_object_type),
          matching_identifier_attribute(:identifier_object_id),
          matching_identifier_attribute(:type),
          matching_polymorphic_ids
        ].compact

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
        query_string.blank? ? nil : table[:cached].eq(query_string)
      end

      # @return [Arel::Node, nil]
      def matching_identifier_object_ids
        matching_identifier_object_ids.empty? ? nil : table[:identifier_object_id].eq_any(matching_identifier_object_ids)
      end

      # @return [Arel::Node, nil]
      def matching_identifier_attribute(attribute)
        v = send(attribute)
        v.blank? ? nil : table[attribute].eq(v)
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

      # @return [Arel::Table]
      def table
        ::Identifier.arel_table
      end

    end
  end
end
