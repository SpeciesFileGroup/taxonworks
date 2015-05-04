require 'rails_helper'
describe Hybrid, :type => :model do

  let(:hybrid) { Hybrid.new }

  specify 'type is Hybrid' do
    expect(hybrid.type).to eq('Hybrid')
  end

  context 'validation' do
    before{hybrid.valid?}
    specify 'is invalid without at least two protonyms' do
      #expect(hybrid.errors.include?(:base)).to be_truthy
    end

    specify 'species combination is valid with two protonyms' do
    end

    specify 'protonyms in the same nomenclatural rank group' do
    end

    specify 'name must be nil' do
      expect(hybrid.errors.include?(:name)).to be_falsey
    end

    # Double check?!
    specify 'rank_class is required' do
      expect(hybrid.errors.include?(:rank_class)).to be_truthy
    end

    specify 'rank should be ICN rank' do
      hybrid.rank_class = 'NomenclaturalRank::Iczn::SpeciesGroup::Species'
      hybrid.valid?
      expect(hybrid.errors.include?(:rank_class)).to be_truthy
      hybrid.rank_class = 'NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Species'
      hybrid.valid?
      expect(hybrid.errors.include?(:rank_class)).to be_falsey
    end
  end

end