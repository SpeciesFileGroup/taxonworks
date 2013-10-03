require 'spec_helper'

describe NomenclaturalRank do

  context 'base methods' do
    specify "rank_name" do
      expect(respond_to(:rank_name)).to be_true
    end

    # TODO: can NomenclaturalRank be abstracted out as "subject" or similar
    specify "abbreviations" do
      expect(respond_to(:abbreviations)).to be_true
      expect(NomenclaturalRank.abbreviations).to eq([])
    end

    specify "common?" do
      expect(respond_to(:common?)).to be_true
    end

    specify "parent_rank" do
      expect(respond_to(:parent_rank)).to be_true
    end
    
    specify "top_rank" do
      expect(respond_to(:top_rank)).to be_true
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
        expect(candidates.size < 2).to be_true
      end
    end 
  end    
end
