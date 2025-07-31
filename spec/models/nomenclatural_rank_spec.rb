require 'rails_helper'

describe NomenclaturalRank, type: :model do

  # Rails.application.eager_load!

  specify 'ranks should have an integer index' do
    rank_class = Ranks.lookup(:iczn, 'family')
    rank_class2 = Ranks.lookup(:iczn, 'genus')
    expect(RANKS.index(rank_class).class).to eq(Integer)
    expect(RANKS.index(rank_class) < RANKS.index(rank_class2)).to be_truthy
  end

  context 'base methods' do
    specify '#abbreviation' do
      expect(NomenclaturalRank).to respond_to(:abbreviation)
      expect(Ranks.lookup(:iczn, 'genus').constantize.abbreviation).to eq('gen.')
    end

    specify { expect(NomenclaturalRank).to respond_to(:rank_name) }
    specify { expect(NomenclaturalRank).to respond_to(:typical_use) }
    specify { expect(NomenclaturalRank).to respond_to(:parent_rank) }

    context '#top_rank' do
      specify { expect(NomenclaturalRank).to respond_to(:top_rank) }

      specify "returns the 'top' assignable rank" do
        # The top two levels
        expect(NomenclaturalRank::Iczn.top_rank).to eq(NomenclaturalRank::Iczn::HigherClassificationGroup::Superkingdom)
        expect(NomenclaturalRank::Icn.top_rank).to eq(NomenclaturalRank::Icn::HigherClassificationGroup::Kingdom)

        # Behaviour is a little different for group levels
        expect(NomenclaturalRank::Iczn::FamilyGroup.top_rank).to eq(NomenclaturalRank::Iczn::FamilyGroup::Superfamily)
      end
    end

    # skip "#bottom_rank"

    specify '#nomenclatural_code' do
      expect(Ranks.lookup(:iczn, 'Family').constantize.nomenclatural_code).to eq(:iczn)
      expect(Ranks.lookup(:icn, 'Class').constantize.nomenclatural_code).to eq(:icn)
    end

    specify '#nomenclatural_code_class' do
      expect(Ranks.lookup(:iczn, 'Family').constantize.nomenclatural_code_class).to eq(NomenclaturalRank::Iczn)
      expect(Ranks.lookup(:iczn, 'Class').constantize.nomenclatural_code_class).to eq(NomenclaturalRank::Iczn)
    end

  end

  context 'relation properties' do
    specify 'recursively following parent_rank class method is a cycle-free path' do
      curr = nil

      NomenclaturalRank.descendants.each do |rank|
        curr = rank
        visited = []
        while !(curr.nil? or visited.include?(curr)) do
          visited << curr
          curr = curr.parent_rank
        end

        expect(curr).to be_nil
      end
    end

    specify 'there is at most on top_rank candidate' do
      NomenclaturalRank.descendants.each do |rank|
        all = rank.descendants
        candidates = all.reject { |r| r.parent_rank.nil? or all.include?(r.parent_rank) }
        expect(candidates.size < 2).to be_truthy
      end
    end
  end
end
