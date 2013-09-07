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

  end
end
