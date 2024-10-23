require 'rails_helper'
require 'support/debug/taxon_names'

describe TaxonName, type: :model, group: [:nomenclature] do

  let(:taxon_name) { TaxonName.new }

  context 'root names' do

    let(:p) { Project.create(name: 'Taxon-name root test.', without_root_taxon_name: true) }

    let(:root1) { Protonym.create!(name: TaxonName::ROOT_NAME, rank_class: 'NomenclaturalRank') }
    let(:root2) { FactoryBot.build(:root_taxon_name) }

    specify 'roots can be created' do
      expect(root1.save!).to be_truthy
    end

    specify 'roots can be created in different projects' do
      root2.project_id = p.id
      expect(root2.save).to be_truthy
    end

    specify 'when name = ROOT_NAME no parent is allowed' do
      n = TaxonName.new(name: TaxonName::ROOT_NAME, parent: TaxonName.new)
      expect(n.valid?).to be_falsey
      expect(n.errors.has_key?(:parent)).to be_truthy
    end

    specify 'a second root in a given project is not allowed' do
      root1
      expect(root2.save).to be_falsey
      expect(root2.errors.include?(:name)).to be_truthy
    end
  end

end 


