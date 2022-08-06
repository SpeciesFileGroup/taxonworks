module Queries
  module Role

    class Filter < Queries::Query
      include Queries::Concerns::Users

      include Concerns::Polymorphic
      polymorphic_klass(::Role)

      # @param role [Array, String]
      #   A valid role name like 'Author' or array like ['TaxonDeterminer', 'SourceEditor'].  See Role descendants.
      # @return [Array]
      attr_accessor :role_type

      # @params params [ActionController::Parameters]
      def initialize(params)
        @role_type = params[:role_type]
        @object_global_id = params[:object_global_id]

        set_user_dates(params)
        set_polymorphic_ids(params)
      end

      def role_type
        [@role_type].flatten.compact
      end

      # @return [Arel::Table]
      def table
        ::Role.arel_table
      end

      def base_query
        ::Role.select('roles.*')
      end

      def role_type_facet
        return nil if role_type.empty?
        table[:type].eq_any(role_type)
      end

      # TODO: DRY.  See also Notes filter
      def object_global_id_facet
        return nil if object_global_id.nil?
        o = GlobalID::Locator.locate(object_global_id)
        k = o.class.base_class.name
        id = o.id
        table[:role_object_id].eq(o.id).and(table[:role_object_type].eq(k))
      end

      # @return [ActiveRecord::Relation, nil]
      def and_clauses
        clauses = [
          role_type_facet,
          object_global_id_facet
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      def merge_clauses
        clauses = [
          created_updated_facet,   # See Queries::Concerns::Users
          matching_polymorphic_ids # See Queries::Concerns::Polymorphic
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = merge_clauses

        if a && b
          b.where(a).distinct
        elsif a
          ::Role.where(a).distinct
        elsif b
          b.distinct
        else
          ::Role.all
        end
      end
    end
  end
end
