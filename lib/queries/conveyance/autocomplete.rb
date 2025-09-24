module Queries
  module Conveyance
    class Autocomplete < Query::Autocomplete

      # [Array] Conveyance object types to restrict search to.
      attr_accessor :polymorphic_types

      def initialize(string, project_id: nil, polymorphic_types: nil)
        super

        @polymorphic_types = polymorphic_types
      end

      # @return [Array]
      def autocomplete
        # TODO reassess if/when this is used for something other than searching
        # for conveyances on Otus.
        # Sound autocomplete already includes queries for conveyances on otus:
        a = Queries::Sound::Autocomplete
          .new(query_string, project_id: project_id).updated_queries

        queries = a.map do |q|
          c = ::Conveyance.where(sound_id: q.pluck(:id))

          if polymorphic_types
            c = c.where(conveyance_object_type: polymorphic_types)
          end

          c
        end

        result = []
        queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end

        result[0..40]
      end
    end
  end
end