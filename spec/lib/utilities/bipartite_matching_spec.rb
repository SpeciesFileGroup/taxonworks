require 'rails_helper'

describe Utilities::BipartiteMatching do

  context '.maximum' do
    def maximum(candidates)
      Utilities::BipartiteMatching.maximum(candidates)
    end

    specify 'pairs each left item with a right item it may pair with' do
      expect(maximum([[1], [0]])).to eq({ 1 => 0, 0 => 1 })
    end

    specify 'pairs each right item with at most one left item' do
      expect(maximum([[0], [0], [1]]).size).to eq(2)
    end

    # Pairing left 0 with its first candidate (right 0) would leave left 1
    # nothing; left 0 has to move to right 1.
    specify 'moves a left item to free a right item' do
      expect(maximum([[0, 1], [0]])).to eq({ 1 => 0, 0 => 1 })
    end

    # Left 3 is only paired by moving 2, which moves 1, which moves 0.
    specify 'moves a chain of left items' do
      pairs = maximum([[0, 1], [1, 2], [2, 3], [0]])
      expect(pairs.size).to eq(4)
      expect(pairs[0]).to eq(3)
    end

    specify 'leaves a left item without candidates unpaired' do
      expect(maximum([[], [0]])).to eq({ 0 => 1 })
    end

    specify 'with nothing to pair' do
      expect(maximum([])).to eq({})
      expect(maximum([[], []])).to eq({})
    end

    specify 'when every pair is allowed' do
      expect(maximum(Array.new(5) { [0, 1, 2] }).size).to eq(3)
    end
  end

end
