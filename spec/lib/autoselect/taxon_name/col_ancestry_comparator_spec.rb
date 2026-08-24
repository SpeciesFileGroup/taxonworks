require 'rails_helper'

# Lightweight double for a real TaxonName ancestor — the comparator only reads
# id, cached, rank_class.
def tw_node(id:, cached:, rank_class:)
  OpenStruct.new(id:, cached:, rank_class:)
end

def col_node(col_name:, col_rank:, col_id: nil, dataset_id: '3LR', col_authorship: nil)
  { col_name:, rank: col_rank, col_id:, dataset_id:, col_authorship: }
end

RSpec.describe Autoselect::TaxonName::ColAncestryComparator, type: :model do
  let(:family_rank)  { Ranks.lookup(:iczn, 'family') }
  let(:genus_rank)    { Ranks.lookup(:iczn, 'genus') }
  let(:subfamily_rank) { Ranks.lookup(:iczn, 'subfamily') }
  let(:tribe_rank)    { Ranks.lookup(:iczn, 'tribe') }

  subject(:comparator) { described_class.new(tw_chain:, col_chain:, col_code: 'zoological') }

  describe '#call' do
    context 'when both chains agree exactly, same length' do
      let(:tw_chain) do
        [
          tw_node(id: 1, cached: 'Hominidae', rank_class: family_rank),
          tw_node(id: 2, cached: 'Homo', rank_class: genus_rank)
        ]
      end
      let(:col_chain) do
        [
          col_node(col_name: 'Hominidae', col_rank: 'family'),
          col_node(col_name: 'Homo', col_rank: 'genus')
        ]
      end

      it 'marks every row exact' do
        result = comparator.call
        expect(result.map { |r| r[:match] }).to eq(%w[exact exact])
      end

      it 'preserves kingdom-first order' do
        result = comparator.call
        expect(result.map { |r| r[:rank] }).to eq(%w[family genus])
      end

      it 'carries the taxonworks id and name on exact rows' do
        result = comparator.call
        expect(result.last[:taxonworks_id]).to eq(2)
        expect(result.last[:taxonworks_name]).to eq('Homo')
      end
    end

    context 'when TaxonWorks has an extra rank CoL does not (subfamily)' do
      let(:tw_chain) do
        [
          tw_node(id: 1, cached: 'Hominidae', rank_class: family_rank),
          tw_node(id: 2, cached: 'Homininae', rank_class: subfamily_rank),
          tw_node(id: 3, cached: 'Homo', rank_class: genus_rank)
        ]
      end
      let(:col_chain) do
        [
          col_node(col_name: 'Hominidae', col_rank: 'family'),
          col_node(col_name: 'Homo', col_rank: 'genus')
        ]
      end

      it 'marks the extra rank as extra, the rest exact' do
        result = comparator.call
        expect(result.map { |r| [r[:rank], r[:match]] }).to eq([
          ['family', 'exact'],
          ['subfamily', 'extra'],
          ['genus', 'exact']
        ])
      end

      it 'extra rows have no CoL data' do
        result = comparator.call
        extra = result.find { |r| r[:match] == 'extra' }
        expect(extra[:col_name]).to be_nil
        expect(extra[:col_id]).to be_nil
        expect(extra[:taxonworks_name]).to eq('Homininae')
      end
    end

    context 'when CoL has an extra rank TaxonWorks does not (tribe)' do
      let(:tw_chain) do
        [
          tw_node(id: 1, cached: 'Hominidae', rank_class: family_rank),
          tw_node(id: 2, cached: 'Homo', rank_class: genus_rank)
        ]
      end
      let(:col_chain) do
        [
          col_node(col_name: 'Hominidae', col_rank: 'family'),
          col_node(col_name: 'Hominini', col_rank: 'tribe'),
          col_node(col_name: 'Homo', col_rank: 'genus')
        ]
      end

      it 'marks the extra CoL rank as none (creatable), the rest exact' do
        result = comparator.call
        expect(result.map { |r| [r[:rank], r[:match]] }).to eq([
          ['family', 'exact'],
          ['tribe', 'none'],
          ['genus', 'exact']
        ])
      end

      it 'none rows have no TaxonWorks data' do
        result = comparator.call
        none_row = result.find { |r| r[:match] == 'none' }
        expect(none_row[:taxonworks_id]).to be_nil
        expect(none_row[:col_name]).to eq('Hominini')
      end
    end

    context 'when the same rank has a genuinely different name in each (the real conflict)' do
      let(:tw_chain) do
        [
          tw_node(id: 1, cached: 'SomeOtherFamily', rank_class: family_rank),
          tw_node(id: 2, cached: 'Homo', rank_class: genus_rank)
        ]
      end
      let(:col_chain) do
        [
          col_node(col_name: 'Hominidae', col_rank: 'family'),
          col_node(col_name: 'Homo', col_rank: 'genus')
        ]
      end

      it 'marks the disagreeing rank as conflict' do
        result = comparator.call
        expect(result.first[:match]).to eq('conflict')
        expect(result.first[:col_name]).to eq('Hominidae')
        expect(result.first[:taxonworks_name]).to eq('SomeOtherFamily')
      end

      it 'still marks the matching rank exact' do
        result = comparator.call
        expect(result.last[:match]).to eq('exact')
      end
    end

    context 'when TW has no real ancestors at all above the anchor (the live Apis bug)' do
      let(:tw_chain) do
        [tw_node(id: 3, cached: 'Apis', rank_class: genus_rank)]
      end
      let(:col_chain) do
        [
          col_node(col_name: 'Apidae', col_rank: 'family'),
          col_node(col_name: 'Apis', col_rank: 'genus')
        ]
      end

      it 'treats the missing TW ancestor as a CoL-only (none) row, not a conflict' do
        result = comparator.call
        expect(result.map { |r| [r[:rank], r[:match]] }).to eq([
          ['family', 'none'],
          ['genus', 'exact']
        ])
      end
    end

    context 'a single-entry (anchor-only) comparison' do
      let(:tw_chain) { [tw_node(id: 1, cached: 'Homo', rank_class: genus_rank)] }
      let(:col_chain) { [col_node(col_name: 'Homo', col_rank: 'genus')] }

      it 'is a single exact row' do
        result = comparator.call
        expect(result.length).to eq(1)
        expect(result.first[:match]).to eq('exact')
      end
    end

    context 'mixed: extra TW rank and extra CoL rank both present' do
      let(:tw_chain) do
        [
          tw_node(id: 1, cached: 'Hominidae', rank_class: family_rank),
          tw_node(id: 2, cached: 'Homininae', rank_class: subfamily_rank),
          tw_node(id: 3, cached: 'Homo', rank_class: genus_rank)
        ]
      end
      let(:col_chain) do
        [
          col_node(col_name: 'Hominidae', col_rank: 'family'),
          col_node(col_name: 'Hominini', col_rank: 'tribe'),
          col_node(col_name: 'Homo', col_rank: 'genus')
        ]
      end

      it 'classifies each independently in kingdom-first order' do
        result = comparator.call
        expect(result.map { |r| [r[:rank], r[:match]] }).to eq([
          ['family', 'exact'],
          ['subfamily', 'extra'],
          ['tribe', 'none'],
          ['genus', 'exact']
        ])
      end
    end
  end
end
