# Pairs items of one side (left) with items of the other (right), each item in
# at most one pair, as many pairs as possible, given which pairs are allowed:
# e.g. the authors of one citation with those of another, a pair allowed when
# their names are close.
#
# Pairing each left item with its first free candidate can come up short: if
# left 0 may pair with right 0 or 1 and left 1 only with right 0, taking right
# 0 for left 0 leaves left 1 nothing. So when a left item's candidate is
# taken, the left item holding it tries to move to another of its own
# candidates, freeing it.
#
# This is Kuhn's algorithm for maximum bipartite matching, and the number of
# pairs is guaranteed to be the largest possible: each left item gets one
# search (.pair) for a chain of such moves ending at a free right item (an
# augmenting path), and by Berge's theorem the pairs are as many as possible
# once no left item has such a chain. Which pairs it settles on may vary; how
# many doesn't.
#
# Speed: up to 100 x 100 items, with any pairs allowed, should be fine.
#
# Usage:
#   Utilities::BipartiteMatching.maximum([[0, 1], [0]])
#   # => { 1 => 0, 0 => 1 } (right => left)
module Utilities::BipartiteMatching

  # @param candidates [Array<Array<Integer>>] per left item (by index), the
  #   right items (indices) it may pair with, in order of preference
  # @return [Hash] right item => the left item paired with it
  def self.maximum(candidates)
    pairs = {}
    candidates.each_index { |left| pair(left, candidates, pairs, Set.new) }
    pairs
  end

  # Pairs `left` with one of its candidates: a free one, or one whose holder
  # can move to another of its own.
  #
  # @param pairs [Hash] right => left, updated
  # @param tried [Set] right items already tried in this search
  # @return [Boolean] whether `left` was paired
  def self.pair(left, candidates, pairs, tried)
    candidates[left].each do |right|
      next if tried.include?(right)

      tried << right
      holder = pairs[right]
      # Taken: ask its holder to move to another of its candidates,
      # recursively (the holder may displace another holder in turn, the
      # chain of moves an augmenting path). `tried` is shared down the chain:
      # a right item no move could free once in this search can't be freed by
      # trying it again, which also ends the recursion.
      if holder.nil? || pair(holder, candidates, pairs, tried)
        pairs[right] = left
        return true
      end
    end
    false
  end
  private_class_method :pair

end
