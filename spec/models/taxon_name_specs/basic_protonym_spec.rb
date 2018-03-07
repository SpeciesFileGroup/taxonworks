require 'rails_helper'

describe TaxonName, type: :model, group: [:nomenclature] do

  context 'basic use' do

    let!(:root) { Protonym.create!(name: 'Root', rank_class: 'NomenclaturalRank', parent_id: nil) }

    let(:family) { Protonym.create!(name: 'Aidae', rank_class: Ranks.lookup(:iczn, :family), parent_id: root.id) }

    let(:params) {
      {
        'name' => 'Test',
        'parent_id' => family.id,
        'rank_class' => 'NomenclaturalRank::Iczn::GenusGroup::Genus'
      }
    }

    specify 'family name only require rank and parent' do
      expect(Protonym.create!(name: 'Aidae', parent: root, rank_class: Ranks.lookup(:iczn, :family))).to be_truthy
    end

    specify 'genus names only require rank and parent' do
      expect(Protonym.create!(name: 'Test', parent: family, rank_class: Ranks.lookup(:iczn, :genus))).to be_truthy
    end

    specify 'genus names only require rank and parent_id' do
      expect(Protonym.create!(name: 'Test', parent_id: family.id, rank_class: Ranks.lookup(:iczn, :genus))).to be_truthy
    end

    specify 'by params' do
      expect(Protonym.create!(params)).to be_truthy
    end
  end
end
