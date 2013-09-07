require 'spec_helper'
require 'ranks'

describe 'Ranks' do

  context 'constants' do
    context 'are build without error from config/initializers/ranks.rb' do
      specify '::RANKS' do
        expect(RANKS).to be_true
      end

      specify '::ICN' do
        expect(ICN).to be_true
      end

      specify '::ICN_LOOKUP' do
        expect(ICN_LOOKUP).to be_true
        expect(ICN_LOOKUP.class).to eq(Hash)
      end

      specify '::ICZN' do
        expect(ICZN).to be_true
      end

      specify '::ICZN_LOOKUP' do
        expect(ICN).to be_true
        expect(ICN_LOOKUP.class).to eq(Hash)
      end
    end

    context 'class methods' do

      specify "top_rank returns top assignable rank" do
        # The top two levels 
        expect(Ranks.top_rank(NomenclaturalRank::Iczn)).to eq(NomenclaturalRank::Iczn::Ungoverned::Superkingdom)
        expect(Ranks.top_rank(NomenclaturalRank::Icn)).to eq(NomenclaturalRank::Icn::Governed::HigherName::Regnum)

        # Behaviour is a little different
        expect(Ranks.top_rank(NomenclaturalRank::Iczn::Governed::FamilyGroup)).to eq(NomenclaturalRank::Iczn::Governed::FamilyGroup::SuperfamilyGroup)
      end

      specify "ordered_ranks_for returns descendant classes" do
        expect(Ranks.ordered_ranks_for(NomenclaturalRank::Icn::Governed::FamilyName)).to eq(
          [NomenclaturalRank::Icn::Governed::FamilyName::Family,
           NomenclaturalRank::Icn::Governed::FamilyName::Subfamily,
           NomenclaturalRank::Icn::Governed::FamilyName::Tribe,
           NomenclaturalRank::Icn::Governed::FamilyName::Subtribe]
        )
      end

    end


  end
end 





