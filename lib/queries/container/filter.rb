module Queries
  module Container
    class Filter < Query::Filter
      include Queries::Concerns::Containable
      include Queries::Concerns::Tags

      PARAMS = [
        :container_id,
        :empty,
        :full,
        :name,
        :name_exact,
        :size_x_max,
        :size_x_min,
        :size_y_max,
        :size_y_min,
        :size_z_max,
        :size_z_min,
        :type,
        contained_object_type: [],
        container_id: [],
        name: [],
        type: [],
      ].freeze

      # @return [Array]
      #   Contained object types, e.g. `CollectionObject`, `Extract`, `Container` or a Container subclass like `Container::Vial`
      #   match containers holding at least one such object (non-recursive)
      attr_accessor :contained_object_type

      attr_accessor :container_id

      # @return [Boolean, nil]
      #   true - containers with no contents (non-recursive)
      #   false - containers with contents
      #   nil - ignored
      attr_accessor :empty

      # @return [Boolean, nil]
      #   true - containers with a size whose contents fill it
      #   false - containers that are not full, including those without a size
      #   nil - ignored
      attr_accessor :full

      # @return [Array]
      attr_accessor :name

      # @return [Boolean]
      #   true - match name exactly
      #   false - wildcard match name
      attr_accessor :name_exact

      # @return [Integer, nil]
      #   the maximum size_x, containers without size_x are excluded
      attr_accessor :size_x_max

      # @return [Integer, nil]
      #   the minimum size_x, containers without size_x are excluded
      attr_accessor :size_x_min

      # @return [Integer, nil]
      #   the maximum size_y, containers without size_y are excluded
      attr_accessor :size_y_max

      # @return [Integer, nil]
      #   the minimum size_y, containers without size_y are excluded
      attr_accessor :size_y_min

      # @return [Integer, nil]
      #   the maximum size_z, containers without size_z are excluded
      attr_accessor :size_z_max

      # @return [Integer, nil]
      #   the minimum size_z, containers without size_z are excluded
      attr_accessor :size_z_min

      # @return [Array]
      attr_accessor :type

      # @param query_params [Hash]
      def initialize(query_params)
        super

        @contained_object_type = params[:contained_object_type]
        @container_id = params[:container_id]
        @empty = boolean_param(params, :empty)
        @full = boolean_param(params, :full)
        @name = params[:name]
        @name_exact = boolean_param(params, :name_exact)
        @size_x_max = params[:size_x_max]
        @size_x_min = params[:size_x_min]
        @size_y_max = params[:size_y_max]
        @size_y_min = params[:size_y_min]
        @size_z_max = params[:size_z_max]
        @size_z_min = params[:size_z_min]
        @type = params[:type]

        set_tags_params(params)
      end

      def contained_object_type
        [@contained_object_type].flatten.compact
      end

      def container_id
        [@container_id].flatten.compact
      end

      def name
        [@name].flatten.compact.collect { |n| n.strip }
      end

      def type
        [@type].flatten.compact
      end

      def container_id_facet
        return nil if container_id.empty?
        table[:id].in(container_id)
      end

      def type_facet
        return nil if type.empty?
        table[:type].in(type)
      end

      def name_facet
        return nil if name.empty?
        if name_exact
          table[:name].in(name)
        else
          table[:name].matches_any(name.collect { |n| '%' + n.gsub(/\s+/, '%') + '%' })
        end
      end

      # @param axis [Symbol] :x, :y, or :z
      def size_facet(axis)
        min = send("size_#{axis}_min")
        max = send("size_#{axis}_max")
        return nil if min.blank? && max.blank?

        column = table["size_#{axis}"]
        clauses = []
        clauses.push column.gteq(min.to_i) if min.present?
        clauses.push column.lteq(max.to_i) if max.present?
        clauses.inject { |a, b| a.and(b) }
      end

      def empty_facet
        return nil if empty.nil?
        empty ? ::Container.where.not(id: populated_containers.select(:id)) : populated_containers
      end

      def full_facet
        return nil if full.nil?
        full ? full_containers : ::Container.where.not(id: full_containers.select(:id))
      end

      # @return [Scope]
      #   Containers with at least one ContainerItem (non-recursive)
      def populated_containers
        ::Container.where(id: ::ContainerItem.containers.where(id: ::ContainerItem.select(:parent_id)).select(:contained_object_id))
      end

      # @return [Scope]
      #   Containers with a size whose ContainerItems (non-recursive) fill or exceed it
      def full_containers
        child_counts = ::ContainerItem.where.not(parent_id: nil).group(:parent_id).select('parent_id, COUNT(*) AS total')

        ::Container
          .joins("JOIN container_items ci ON ci.contained_object_id = containers.id AND ci.contained_object_type = 'Container'")
          .joins("JOIN (#{child_counts.to_sql}) child_counts ON child_counts.parent_id = ci.id")
          .where('containers.size_x IS NOT NULL')
          .where('child_counts.total >= COALESCE(containers.size_x, 1) * COALESCE(containers.size_y, 1) * COALESCE(containers.size_z, 1)')
      end

      def contained_object_type_facet
        return nil if contained_object_type.empty?

        container_types = contained_object_type.select { |t| t.start_with?('Container::') }
        object_types = contained_object_type - container_types

        c = ::ContainerItem.arel_table
        child_containers = ::Container.arel_table.alias('child_containers')

        clauses = []
        clauses.push c[:contained_object_type].in(object_types) if object_types.any?
        clauses.push child_containers[:type].in(container_types) if container_types.any?

        holders = ::ContainerItem
          .joins("JOIN container_items parent_items ON parent_items.id = container_items.parent_id AND parent_items.contained_object_type = 'Container'")
          .joins("LEFT JOIN containers child_containers ON child_containers.id = container_items.contained_object_id AND container_items.contained_object_type = 'Container'")
          .where(clauses.inject { |a, b| a.or(b) })
          .select('parent_items.contained_object_id')

        ::Container.where(id: holders)
      end

      # Overrides Queries::Concerns::Containable, aliasing the enclosing
      # containers table to avoid a conflict with the referenced `containers` table
      def referenced_klass_containers
        referenced_klass_with_container_items
          .joins("JOIN containers enclosing_containers ON enclosing_containers.id = ci2.contained_object_id AND ci2.contained_object_type = 'Container'")
      end

      # Overrides Queries::Concerns::Containable, see #referenced_klass_containers
      def referenced_klass_container_identifiers
        referenced_klass_containers
          .joins("JOIN identifiers ON identifiers.identifier_object_id = enclosing_containers.id AND identifiers.identifier_object_type = 'Container'")
      end

      def and_clauses
        [
          container_id_facet,
          type_facet,
          name_facet,
          size_facet(:x),
          size_facet(:y),
          size_facet(:z)
        ]
      end

      def merge_clauses
        [
          contained_object_type_facet,
          empty_facet,
          full_facet
        ]
      end

    end
  end
end
