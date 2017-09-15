require 'rails_helper'

describe TaxonName, type: :model, group: [:nomenclature] do

  let(:root) { FactoryGirl.create(:root_taxon_name) }
  let(:source) { FactoryGirl.create(:valid_source, year: 1927) }

  context 'assigning year to authorship string' do
    let!(:species) { Protonym.create(name: 'aus', parent: root, rank_class: Ranks.lookup(:iczn, :species), source: source) }

    specify 'year comes from source' do
      expect(species.cached_author_year).to match('1927')
    end

    context 'with taxon name author roles' do
      let(:person) { Person.create(last_name: 'Smith') }

      before {  species.taxon_name_authors << person }

      #specify 'check a role is created' do
      #  expect(species.roles.count).to eq(1)
      #end

      specify 'year still comes from source' do
        expect(species.reload.cached_author_year).to match('1927')
      end

    end

  end
end
