module Queries
  module Observation 

    # !! does not inherit from base query
    class Filter 

      # General annotator options handling 
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      attr_accessor :options

      # Params specific to AlternateValue
      attr_accessor :observation_object_global_id, :otu_id, :collection_object_id, :descriptor_id, :character_state_id, :type

      def initialize(params)
        @otu_id = params[:otu_id]
        @observation_object_global_id = params[:observation_object_global_id]
        @collection_object_id = params[:collection_object_id]
        @descriptor_id = params[:descriptor_id]
        @character_state_id = params[:character_state_id]
        @type = params[:type]
       
        @options = params 
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          matching_descriptor_id,
          matching_observation_object_global_id
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Arel::Node, nil]
      def matching_observation_object_global_id
        if  observation_object_global_id.blank?
          nil
        else
        
          # TODO - make a hash method to parameterize these values 
          o = GlobalID::Locator.locate(observation_object_global_id) 

          case o.metamorphosize.class.name
          when 'Otu'
            table[:otu_id].eq(o.id) 
          when 'CollectionObject'
            table[:collection_object_id].eq(o.id) 
          else
            return nil
          end
        end
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

      # @return [Arel::Node, nil]
      def matching_otu_id
        otu_id.blank? ? nil : table[:otu_id].eq(otu_id) 
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::Observation.where(and_clauses)
        else
          ::Observation.none
        end
      end

      # @return [Arel::Table]
      def table
        ::Observation.arel_table
      end
    end
  end
end
