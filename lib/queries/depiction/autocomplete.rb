module Queries
  module Depiction
    class Autocomplete < Query::Autocomplete

      attr_accessor :polymorphic_types

      def initialize(string, project_id: nil, polymorphic_types: nil)
        super

        @polymorphic_types = polymorphic_types
      end

      # @return [Array]
      def autocomplete
        # TODO reassess if/when this is used for something other than searching
        # for depictions on Otus.
        # Image autocomplete already includes queries for depictions on otus:
        a = Queries::Image::Autocomplete
          .new(query_string, project_id: project_id).updated_queries
          byebug

        queries = a.map do |q|
          d = ::Depiction.where(image_id: q.select(:id))

          if polymorphic_types
            d = d.where(depiction_object_type: polymorphic_types)
          end

          d
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