# Evaluates PostgreSQL `pg_trgm` functions on strings given by the caller,
# many at once, in one query. What's compared, and how it's normalized,
# is the caller's business; this only runs the functions.
#
# Usage:
#   Utilities::Rails::Trigrams.evaluate([
#     ['Fleas of Indiana', 'Fleas of Indiana', :similarity],
#     ['Fleas of Indiana', 'Smith 1990. Fleas of Indiana. J. Parasitology',
#       :word_similarity]
#   ])
#   # => { [...first...] => 1.0, [...second...] => 1.0 }
module Utilities::Rails::Trigrams

  FUNCTIONS = %i{similarity word_similarity}.freeze

  # @param comparisons [Array<Array>] each [a, b, function], function one
  #   of FUNCTIONS:
  #   - :similarity - `similarity(a, b)`: how alike a and b are as wholes;
  #     symmetric
  #   - :word_similarity - `word_similarity(a, b)`: how well a matches the
  #     stretch of b most like it, e.g. a title within a whole citation; not
  #     symmetric
  # @return [Hash] comparison => Float 0..1
  def self.evaluate(comparisons)
    comparisons = comparisons.uniq
    return {} if comparisons.empty?

    # Each distinct string is sent once; comparisons refer to them by
    # number.
    number = {}
    comparisons.each do |a, b, _|
      number[a] ||= number.size
      number[b] ||= number.size
    end

    conn = ::ActiveRecord::Base.connection
    strings = number.map { |s, i| "(#{i}, #{conn.quote(s)}::text)" }
    pairs = comparisons.each_with_index.map { |(a, b, function), i|
      if !FUNCTIONS.include?(function)
        raise ArgumentError, "unknown function #{function}"
      end

      "(#{i}, #{number[a]}, #{number[b]}, #{function == :word_similarity})"
    }

    values = conn.select_rows(<<~SQL).to_h { |i, v| [i.to_i, v.to_f] }
      WITH strings(i, s) AS (VALUES #{strings.join(', ')}),
        pairs(i, a, b, word) AS (VALUES #{pairs.join(', ')})
      SELECT pairs.i,
        CASE WHEN pairs.word THEN word_similarity(a.s, b.s)
          ELSE similarity(a.s, b.s) END
      FROM pairs
      JOIN strings a ON a.i = pairs.a
      JOIN strings b ON b.i = pairs.b
    SQL

    comparisons.each_with_index.to_h { |c, i| [c, values[i]] }
  end

end
