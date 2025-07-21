module Queries
  module Conveyance
    class Filter < Query::Filter

      PARAMS = [
        *::Conveyance.related_foreign_keys.map(&:to_sym),
        :conveyance_id,
        :name,
        :conveyance_object_type,
        :conveyance_object_id,
        :sound_id,
        :otu_id,
        sound_id: [],
        conveyance_id: [],
        conveyance_object_id: [],
        conveyance_object_type: [],
        otu_id: [],
        otu_scope: [],
      ].freeze

      # @return Array
      attr_accessor :conveyance_id

      # @param name [String, nil]
      #   wildcard wrapped, always, to match against `name`
      attr_accessor :name

      # @return [Array]
      # @params conveyance_object_type array or string
      attr_accessor :conveyance_object_type

      # @return [Array]
      # @params conveyance_object_id array or string (integer)
      attr_accessor :conveyance_object_id

      # @return [Array]
      # @params sound_id array or string (integer)
      attr_accessor :sound_id

      # @return [Array]
      # @params otu_id array or string (integer)
      attr_accessor :otu_id

      # @return [Array]
      # @params otu_scope array
      attr_accessor :otu_scope

      def initialize(query_params)
        super

        @conveyance_id = params[:conveyance_id]
        @name = params[:name]
        @conveyance_object_type = params[:conveyance_object_type]
        @conveyance_object_id = params[:conveyance_object_id]
        @sound_id = params[:sound_id]
        @otu_id = params[:otu_id]
        @otu_scope = params[:otu_scope]
      end

      def conveyance_id
        [@conveyance_id].flatten.compact
      end

      def conveyance_object_id
        [@conveyance_object_id].flatten.compact
      end

      def conveyance_object_type
        [@conveyance_object_type].flatten.compact
      end

      def sound_id
        [@sound_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def otu_scope
        [@otu_scope].flatten.compact.map(&:to_sym)
      end

      def name_facet
        return nil if name.blank?
        table[:name].matches('%' + name + '%')
      end

      def conveyance_object_type_facet
        return nil if conveyance_object_type.empty?
        table[:conveyance_object_type].in(conveyance_object_type)
      end

      def conveyance_object_id_facet
        return nil if conveyance_object_id.empty?
        table[:conveyance_object_id].in(conveyance_object_id)
      end

      def sound_id_facet
        return nil if sound_id.empty?
        table[:sound_id].in(sound_id)
      end

      def sound_query_facet
        return nil if sound_query.nil?
        ::Conveyance.with(sound_query: sound_query.all )
          .joins('JOIN sound_query as sound_query1 on sound_query1.id = conveyances.sound_id')
          .distinct
      end

      def otu_facet_otus(otu_ids)
        ::Conveyance.where(conveyances: { conveyance_object_type: 'Otu', conveyance_object_id: otu_ids })
      end

      def otu_facet
        return nil if otu_id.empty? || !otu_scope.empty?
        otu_facet_otus(otu_id)
      end

      def otu_facet_collection_objects(otu_ids)
        fo = ::CollectionObject.joins(:taxon_determinations)
          .where(taxon_determinations: { otu_id: otu_ids })


        ::Conveyance
          .with(co_query: fo)
          .joins("JOIN co_query on co_query.id = conveyance_object_id and conveyance_object_type = 'CollectionObject'")
      end

      def otu_facet_field_occurrences(otu_ids)
        fo = ::FieldOccurrence.joins(:taxon_determinations)
          .where(taxon_determinations: { otu_id: otu_ids })

        ::Conveyance
          .with(co_query: fo)
          .joins("JOIN co_query on co_query.id = conveyance_object_id and conveyance_object_type = 'FieldOccurrence'")
      end

      def otu_scope_facet
        return nil if otu_id.empty? || otu_scope.empty?

        otu_ids = otu_id
        otu_ids += ::Otu.coordinate_otu_ids(otu_id) if otu_scope.include?(:coordinate_otus)
        otu_ids.uniq!

        selected = []

        if otu_scope.include?(:all)
          selected = [
            :otu_facet_otus,
            :otu_facet_collection_objects,
            :otu_facet_field_occurrences,
          ]
        elsif otu_scope.empty?
          selected = [:otu_facet_otus]
        else
          selected.push :otu_facet_otus if otu_scope.include?(:otus)
          selected.push :otu_facet_collection_objects if otu_scope.include?(:collection_objects)
          selected.push :otu_facet_field_occurrences if otu_scope.include?(:field_occurrences)
        end

        ::Queries.union(::Conveyance, selected.collect{|a| send(a, otu_ids) })
      end

      def merge_clauses
        [
          sound_query_facet,
          otu_facet,
          otu_scope_facet
        ].compact
      end

      def and_clauses
        [
          name_facet,
          conveyance_object_id_facet,
          conveyance_object_type_facet,
          sound_id_facet
        ]
      end
    end
  end
end
