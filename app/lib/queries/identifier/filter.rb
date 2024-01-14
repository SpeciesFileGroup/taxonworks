module Queries
  module Identifier

    class Filter < Query::Filter

      include Concerns::Polymorphic
      polymorphic_klass(::Identifier)

      PARAMS = [
        *::Identifier.related_foreign_keys.map(&:to_sym),
        :identifier,
        :identifier_id,
        :identifier_object_id,
        :identifier_object_type,
        :namespace_id,
        :namespace_name,
        :namespace_short_name,
        :query_string,
        :type,
        identifier: [],
        identifier_id: [],
        identifier_object_id: [],
        identifier_object_type: [],
        namespace_id: [],
      ].freeze

      # @return Array
      attr_accessor :identifier_id

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

      # @return Array
      attr_accessor :identifier_object_id

      # @return Array
      attr_accessor :type

      # TODO: community likely broken/intercept somewhere
      # attr_accessor :project_id

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super

        @identifier = params[:identifier]
        @identifier_id = params[:identifier_id]
        @identifier_object_id = params[:identifier_object_id]
        @identifier_object_type = params[:identifier_object_type]
        @namespace_id = params[:namespace_id]
        @namespace_name = params[:namespace_name]
        @namespace_short_name = params[:namespace_short_name]
        @query_string = params[:query_string]
        @type = params[:type]

        set_polymorphic_params(params)
      end

      def type
        [@type].flatten.compact.uniq
      end

      def identifier_id
        [@identifier_id].flatten.compact.uniq
      end

      def namespace_id
        [@namespace_id].flatten.compact.uniq
      end

      def identifier
        [@identifier].flatten.compact.uniq
      end

      def identifier_object_type
        [@identifier_object_type].flatten.compact
      end

      def identifier_object_id
        [@identifier_object_id].flatten.compact
      end

      def annotated_class
        # !! May be some base-class requirements here?!
        if identifier_object_type.present?
          identifier_object_type
        elsif polymorphic_type.present?
          [polymorphic_type]
        else
          [::Queries::Annotator.annotated_class(params, ::Identifier)]
        end
      end

      def ignores_project?
        # Use the same constant - TODO: move it dual annotator likely
        ::Identifier::ALWAYS_COMMUNITY & annotated_class == annotated_class
      end

      # Ommits non community klasses of identifiers
      def community_project_id_facet
        return nil if project_id.nil?
        if !ignores_project?
          # Not a community class
          return table[:project_id].in(project_id)
        else
          # Is a community class
          # Identifiers that are not local only
          return table[:type].matches('Identifier::Global%').or(table[:project_id].in(project_id))
        end
        nil
      end

      def cached_facet
        return nil if query_string.blank?
        table[:cached].matches('%' + query_string + '%')
      end

      def identifier_object_id_facet
        return nil if identifier_object_id.empty?
        table[:identifier_object_id].in(identifier_object_id)
      end

      def identifier_object_type_facet
        return nil if identifier_object_type.empty?
         table[:identifier_object_type].in(identifier_object_type)
      end

      def matching_identifier_attribute(attribute)
        v = send(attribute)
        v.blank? ? nil : table[attribute].in(v)
      end

      def matching_namespace(attribute)
        v = self.send("namespace_#{attribute}")
        return nil if v.blank?
        o = table
        n = ::Namespace.arel_table

        a = o.alias('a_')
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

      def project_id_facet
        if ignores_project?
          nil
       else
         super
       end
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        [
          cached_facet,
          matching_identifier_attribute(:identifier),
          matching_identifier_attribute(:namespace_id),
          matching_identifier_attribute(:type),
          identifier_object_id_facet,
          identifier_object_type_facet,
          community_project_id_facet,
        ]
      end

      def merge_clauses
        [
          matching_namespace(:short_name),
          matching_namespace(:name),
        ]
      end

    end
  end
end
