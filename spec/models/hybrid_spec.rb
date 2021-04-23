require 'rails_helper'
describe Hybrid, type: :model, group: [:nomenclature]  do
  # must be executed first so that it is the root name used in the valid_hybrid
  let!(:root) { FactoryBot.create(:root_taxon_name) }

  let(:hybrid) { Hybrid.new }
  let(:valid_hybrid) { FactoryBot.create(:valid_hybrid) }

  # let(:hybrid_relationship) { TaxonNameRelationship::Hybrid.new }
  # let(:g) { Protonym.create(name: 'Aus', parent: root, rank_class: Ranks.lookup(:icn, :genus)) }
  # let(:s1) { Protonym.create(name: 'aus', parent: g, rank_class: Ranks.lookup(:icn, :species)) }
  # let(:s2) { Protonym.create(name: 'bus', parent: g, rank_class: Ranks.lookup(:icn, :species)) }

  specify 'type is Hybrid' do
    expect(hybrid.type).to eq('Hybrid')
  end

  # These are  not relationship tests!
  context 'cached values' do
    # valid_hybrid factory includes relationships now

    specify 'cached_html' do
      expect(valid_hybrid.cached_html).to eq('<i>Aus cus</i> × <i>Aus dus</i>')
    end 

    specify 'cached' do
      expect(valid_hybrid.cached).to eq('Aus cus x Aus dus')
    end
  end

  context 'soft validation' do
    specify 'is soft valid when at least two relationships to non hybrid taxa are required' do
      valid_hybrid.soft_validate(only_sets: :hybrid_name_relationships)
      expect(valid_hybrid.soft_validations.messages_on(:base).count).to eq(0)
    end

    specify 'is not soft valid when at least two relationships to non hybrid taxa are required' do
      valid_hybrid.hybrid_relationships.first.destroy
      valid_hybrid.reload
      valid_hybrid.soft_validate(only_sets: :hybrid_name_relationships)
      expect(valid_hybrid.soft_validations.messages_on(:base).count).to eq(1)
    end
  end

  context 'validation' do
    before{ hybrid.valid? }

    specify 'protonyms in the same nomenclatural rank group' do
    end

    specify 'rank_class' do
      expect(hybrid.errors.include?(:rank_class)).to be_truthy
    end

    specify 'name must be nil' do
      expect(hybrid.errors.include?(:name)).to be_falsey
    end

    # Double check?!
    specify 'rank_class is required' do
      expect(hybrid.errors.include?(:rank_class)).to be_truthy
    end

    # TODO: @proceps this is not a good test of valid, didn't catch the bad rank?
    specify 'rank is valid when ICN rank' do 
      hybrid.rank_class = 'NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup::Species'
      hybrid.valid?
      expect(hybrid.errors.include?(:rank_class)).to be_falsey
    end

    specify 'rank is invalid when ICZN rank' do
      hybrid.rank_class = 'NomenclaturalRank::Iczn::SpeciesGroup::Species'
      hybrid.valid?
      expect(hybrid.errors.include?(:rank_class)).to be_truthy
    end
  end

end
