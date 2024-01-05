Rails.application.reloader.to_prepare do
  require 'rails_helper'
  require 'ranks'
end

describe 'Ranks' do

  # Rails.application.eager_load!

  context 'constants' do
    context 'are build without error from config/initializers/ranks.rb' do
      specify '::RANKS' do
        expect(RANKS).to be_truthy
      end

      specify '::RANKS_SELECT_OPTIONS' do
        expect(RANKS_SELECT_OPTIONS).to be_truthy
      end

      specify '::ICN' do
        expect(ICN).to be_truthy
      end

      specify '::ICN_LOOKUP' do
        expect(ICN_LOOKUP).to be_truthy
        expect(ICN_LOOKUP.class).to eq(Hash)
      end

      specify '::ICZN' do
        expect(ICZN).to be_truthy
      end

      specify '::ICZN_LOOKUP' do
        expect(ICZN).to be_truthy
        expect(ICZN_LOOKUP.class).to eq(Hash)
      end
    end

    context 'class methods' do
      specify 'top_rank returns top assignable rank' do
        # The top two levels

        expect(NomenclaturalRank::Iczn.top_rank).to eq(NomenclaturalRank::Iczn::HigherClassificationGroup::Superkingdom)
        expect(NomenclaturalRank::Icn.top_rank).to eq(NomenclaturalRank::Icn::HigherClassificationGroup::Kingdom)



#       expect(NomenclaturalRank.top_rank(NomenclaturalRank::Iczn)).to eq(NomenclaturalRank::Iczn::HigherClassificationGroup::Superkingdom)
#       expect(NomenclaturalRank.top_rank(NomenclaturalRank::Icn)).to eq(NomenclaturalRank::Icn::HigherClassificationGroup::Kingdom)

        # Behaviour is a little different
        expect(NomenclaturalRank::Iczn::FamilyGroup.top_rank).to eq(NomenclaturalRank::Iczn::FamilyGroup::Superfamily)
      end

      specify 'Class#ordered_ranks returns descendant classes' do
        expect(NomenclaturalRank::Icn::FamilyGroup.ordered_ranks).to eq(
          [NomenclaturalRank::Icn::FamilyGroup::Family,
           NomenclaturalRank::Icn::FamilyGroup::Subfamily,
           NomenclaturalRank::Icn::FamilyGroup::Tribe,
           NomenclaturalRank::Icn::FamilyGroup::Subtribe]
        )
      end

      specify 'rank.lookup return false' do
        expect(Ranks.lookup(:iczn, 'false')).to be_falsey
      end

      specify 'rank.lookup return proper class for ICZN rank' do
        expect(Ranks.lookup(:iczn, 'Family').to_s).to eq('NomenclaturalRank::Iczn::FamilyGroup::Family')
      end

      specify 'rank.lookup return proper class for ICN rank' do
        expect(Ranks.lookup(:icn, 'Family').to_s).to eq('NomenclaturalRank::Icn::FamilyGroup::Family')
      end
    end



  end
end
