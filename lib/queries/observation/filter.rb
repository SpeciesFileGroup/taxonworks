module Queries
  module Observation

    # !! TODO: needs tests
    class Filter < Query::Filter

      attr_accessor :observation_object_global_id
      attr_accessor :otu_id
      attr_accessor :collection_object_id
      attr_accessor :descriptor_id
      attr_accessor :character_state_id
      attr_accessor :type

      # @return [Integer, nil]
      #   not extended to Array yet
      attr_accessor :observation_matrix_id

      def initialize(params)
        @otu_id = params[:otu_id]
        @collection_object_id = params[:collection_object_id]
        @observation_object_global_id = params[:observation_object_global_id]
        @descriptor_id = params[:descriptor_id]
        @type = params[:type]

        @character_state_id = params[:character_state_id]

        @observation_matrix_id = params[:observation_matrix_id]
      end

      def observation_matrix_id_facet
        return nil if observation_matrix_id.nil?
        ::Observation.in_observation_matrix(observation_matrix_id)
      end

      def merge_clauses
        clauses = [
          observation_matrix_id_facet
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          matching_descriptor_id,
          matching_otu_id,
          matching_collection_object_id,
          matching_observation_object_global_id,
          matching_character_state_id
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Arel::Node, nil]
      def matching_observation_object_global_id
        return nil if observation_object_global_id.blank?

        # TODO - make a hash method to parameterize these values
        o = GlobalID::Locator.locate(observation_object_global_id)

        a = o.id
        b = o.class.base_class.name

        table[:observation_object_id].eq(a).and(table[:observation_object_type].eq(b))
      end

      # @return [Arel::Node, nil]
      def matching_character_state_id
        character_state_id.blank? ? nil : table[:character_state_id].eq(character_state_id)
      end

      # @return [Arel::Node, nil]
      def matching_collection_object_id
        collection_object_id.blank? ? nil : table[:observation_object_id].eq(collection_object_id).and(table[:observation_object_type].eq('CollectionObject'))
      end

      # @return [Arel::Node, nil]
      def matching_type
        type.blank? ? nil : table[:type].eq(type)
      end

      # @return [Arel::Node, nil]
      def matching_descriptor_id
        descriptor_id.blank? ? nil : table[:descriptor_id].eq(descriptor_id)
      end

      # @return [Arel::Node, nil]
      def matching_character_state_id
        character_state_id.blank? ? nil : table[:character_state_id].eq(character_state_id)
      end

      # TODO: make Array or individual
      # @return [Arel::Node, nil]
      def matching_otu_id
        otu_id.blank? ? nil : table[:observation_object_id].eq(otu_id).and(table[:observation_object_type].eq('Otu'))
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = merge_clauses

        q = nil
        if a && b
          q = b.where(a)
        elsif a
          q = ::Observation.where(a)
        elsif b
          q = b
        else
          q = ::Observation.all
        end

        q
      end

    end
  end
end
