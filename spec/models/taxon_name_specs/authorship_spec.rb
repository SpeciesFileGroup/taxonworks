require 'rails_helper'

describe TaxonName, type: :model, group: [:nomenclature] do

  let(:root) { FactoryGirl.create(:root_taxon_name) }
  let(:source) { FactoryGirl.create(:valid_source, year: 1927) }
  let(:person) { Person.create(last_name: 'Smith') }

  context 'assigning year to authorship string' do
    let!(:species) { Protonym.create(name: 'aus', parent: root, rank_class: Ranks.lookup(:iczn, :species), source: source) }

    specify 'year comes from source' do
      expect(species.cached_author_year).to match('1927')
    end

    context 'with taxon name author roles' do
      before {  species.taxon_name_authors << person }

      #specify 'check a role is created' do
      #  expect(species.roles.count).to eq(1)
      #end

      specify 'year still comes from source' do
        expect(species.cached_author_year).to match('1927')
      end
    end

    context 'using update' do
      before {  species.update(roles_attributes: [{person_id: person.id, type: 'TaxonNameAuthor'}]) }

      specify 'updates #cached_author_year' do
        expect(species.cached_author_year).to eq('Smith, 1927')
      end
    end

  end
end
