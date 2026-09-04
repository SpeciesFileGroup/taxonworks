# Shared batch-matching mechanics for Match::Otu::* matchers: matches each unique input
# name once (memoized), then re-expands the memoized results back over the original,
# possibly-duplicated, order-preserving input array.
#
# Includers must define `names` and a private `match_name(name)` returning a result Hash.
module Match
  module Otu
    module NameBatchMatcher
      MAX_NAMES = 3000

      # @return [Array<Hash>]
      def call
        unique_names = names.uniq
        match_cache = {}

        unique_names.each do |name|
          match_cache[name] = match_name(name)
        end

        names.map { |name| match_cache[name].merge(scientific_name: name) }
      end
    end
  end
end
