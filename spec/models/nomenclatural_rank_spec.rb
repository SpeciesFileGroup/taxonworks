require 'rails_helper'

describe NomenclaturalRank, :type => :model do

  context 'David' do
    specify 'ranks should have an integer index' do
        rank_class = Ranks.lookup(:iczn, 'family')
        rank_class2 = Ranks.lookup(:iczn, 'genus')
        expect(RANKS.index(rank_class).class).to eq(Fixnum)
        expect(RANKS.index(rank_class) < RANKS.index(rank_class2)).to be_truthy
    end
  end

  context 'base methods' do
    specify "rank_name" do
      expect(NomenclaturalRank).to respond_to(:rank_name)
    end

    # TODO: can NomenclaturalRank be abstracted out as "subject" or similar
    specify "abbreviation" do
      expect(NomenclaturalRank).to respond_to(:abbreviation)
      expect(Ranks.lookup(:iczn, 'genus').abbreviation).to eq("gen.")
    end

    specify "common?" do
      expect(NomenclaturalRank).to respond_to(:typical_use)
    end

    specify "parent_rank" do
      expect(NomenclaturalRank).to respond_to(:parent_rank)
    end
    
    specify "top_rank" do
      expect(NomenclaturalRank).to respond_to(:top_rank)
    end

    specify "nomenclatural_code" do
      expect(Ranks.lookup(:iczn, 'Family').nomenclatural_code).to eq(:iczn)
      expect(Ranks.lookup(:icn, 'Class').nomenclatural_code).to eq(:icn)

    end

    specify "nomenclatural_code_class" do
      expect(Ranks.lookup(:iczn, "Family").nomenclatural_code_class).to eq(NomenclaturalRank::Iczn)
      expect(Ranks.lookup(:iczn, "Class").nomenclatural_code_class).to eq(NomenclaturalRank::Iczn)
    end

    # TODO: This functionality was first specified in spec/lib/ranks_spec.rb. 
    #       We need to decide which one should be implementing this method.
    specify "top_rank returns top assignable rank" do
      # The top two levels 
      expect(NomenclaturalRank.top_rank(NomenclaturalRank::Iczn)).to eq(NomenclaturalRank::Iczn::HigherClassificationGroup::Superkingdom)
      expect(NomenclaturalRank.top_rank(NomenclaturalRank::Icn)).to eq(NomenclaturalRank::Icn::HigherClassificationGroup::Kingdom)

      # Behaviour is a little different
      expect(NomenclaturalRank.top_rank(NomenclaturalRank::Iczn::FamilyGroup)).to eq(NomenclaturalRank::Iczn::FamilyGroup::SuperfamilyGroup)
    end    
  end
  
  context 'relation properties' do
    specify "recursively following parent_rank class method is a cycle-free path" do
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
    
    specify "there is one top_rank candidate at most" do
      NomenclaturalRank.descendants.each do |rank|
        all = rank.descendants
        candidates = all.reject { |r| r.parent_rank.nil? or all.include?(r.parent_rank) }
        expect(candidates.size < 2).to be_truthy
      end
    end 
  end    
end
