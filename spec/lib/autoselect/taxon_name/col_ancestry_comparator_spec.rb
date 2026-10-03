require 'rails_helper'

# Lightweight double for a real TaxonName ancestor — the comparator only reads
# id, cached, name, rank_class.
def tw_node(id:, cached:, rank_class:, name: cached)
  OpenStruct.new(id:, cached:, name:, rank_class:)
end

def col_node(col_name:, col_rank:, col_id: nil, dataset_id: '3LR', col_authorship: nil)
  { col_name:, rank: col_rank, col_id:, dataset_id:, col_authorship: }
end

RSpec.describe Autoselect::TaxonName::ColAncestryComparator, type: :model do
  let(:family_rank)  { Ranks.lookup(:iczn, 'family') }
  let(:genus_rank)    { Ranks.lookup(:iczn, 'genus') }
  let(:subfamily_rank) { Ranks.lookup(:iczn, 'subfamily') }
  let(:tribe_rank)    { Ranks.lookup(:iczn, 'tribe') }
  let(:subgenus_rank) { Ranks.lookup(:iczn, 'subgenus') }

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

    context 'when a CoL-only rank has no TaxonWorks equivalent' do
      let(:tw_chain) do
        [tw_node(id: 2, cached: 'Homo', rank_class: genus_rank)]
      end
      let(:col_chain) do
        [
          col_node(col_name: 'Osteichthyes', col_rank: 'parvphylum')
            .merge(rank_unknown: true),
          col_node(col_name: 'Homo', col_rank: 'genus')
        ]
      end

      it 'carries rank_unknown onto its none row' do
        none_row = comparator.call.find { |r| r[:match] == 'none' }
        expect(none_row[:rank]).to eq('parvphylum')
        expect(none_row[:rank_unknown]).to be(true)
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

    context 'a subgenus (TW cached is "Genus (Subgenus)", CoL gives the bare epithet)' do
      let(:tw_chain) do
        [
          tw_node(id: 1, cached: 'Aus', rank_class: genus_rank),
          tw_node(id: 2, cached: 'Aus (Bus)', name: 'Bus',
            rank_class: subgenus_rank)
        ]
      end
      let(:col_chain) do
        [
          col_node(col_name: 'Aus', col_rank: 'genus'),
          col_node(col_name: 'Bus', col_rank: 'subgenus')
        ]
      end

      it 'matches the subgenus on its name, not its cached combination' do
        result = comparator.call
        expect(result.map { |r| r[:match] }).to eq(%w[exact exact])
      end

      it 'still reports the TW cached combination as the taxonworks name' do
        expect(comparator.call.last[:taxonworks_name]).to eq('Aus (Bus)')
      end
    end

    context 'a species TW places under a subgenus that CoL names without it' do
      let(:species_rank) { Ranks.lookup(:iczn, :species) }
      let(:tw_chain) do
        [tw_node(id: 1, cached: 'Aus (Bus) cus', name: 'cus',
          rank_class: species_rank)]
      end
      let(:col_chain) { [col_node(col_name: 'Aus cus', col_rank: 'species')] }

      it 'is exact' do
        expect(comparator.call.first[:match]).to eq('exact')
      end
    end

    context 'a subgenus whose name genuinely differs from CoL' do
      let(:tw_chain) do
        [tw_node(id: 1, cached: 'Aus (Bus)', name: 'Bus',
          rank_class: subgenus_rank)]
      end
      let(:col_chain) { [col_node(col_name: 'Cus', col_rank: 'subgenus')] }

      it 'is a conflict' do
        expect(comparator.call.first[:match]).to eq('conflict')
      end
    end

    context 'when CoL gives no nomenclatural code' do
      # Real TaxonNames carry a Class in rank_class, which the code-fallback
      # reads `nomenclatural_code` from.
      let(:icn_genus_rank) { Ranks.lookup(:icn, 'genus').constantize }
      let(:icn_section_rank) { Ranks.lookup(:icn, 'section').constantize }
      let(:icn_species_rank) { Ranks.lookup(:icn, 'species').constantize }

      let(:tw_chain) do
        [
          tw_node(id: 1, cached: 'Aus', rank_class: icn_genus_rank),
          tw_node(id: 2, cached: 'Aus sect. Bus', name: 'Bus',
            rank_class: icn_section_rank),
          tw_node(id: 3, cached: 'Aus cus', name: 'cus',
            rank_class: icn_species_rank)
        ]
      end
      let(:col_chain) do
        [
          col_node(col_name: 'Aus', col_rank: 'genus'),
          col_node(col_name: 'Aus cus', col_rank: 'species')
        ]
      end

      subject(:comparator) do
        described_class.new(tw_chain:, col_chain:, col_code: nil)
      end

      it "orders ranks under the anchor's own code" do
        result = comparator.call
        expect(result.map { |r| [r[:rank], r[:match]] }).to eq([
          ['genus', 'exact'],
          ['section', 'extra'],
          ['species', 'exact']
        ])
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
