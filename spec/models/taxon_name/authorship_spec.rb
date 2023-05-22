require 'rails_helper'

describe TaxonName, type: :model, group: [:nomenclature] do

  let(:root) { FactoryBot.create(:root_taxon_name) }
  let(:source) { FactoryBot.create(:valid_source, year: 1927, author: 'Ivanov & Petrov') }
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

  context 'icn' do
    let!(:genus) { Protonym.create(name: 'Aus', parent: root, rank_class: Ranks.lookup(:icn, :genus)) }
    let!(:species) { Protonym.create(name: 'aus', verbatim_author: 'Ivanov', parent: genus, rank_class: Ranks.lookup(:icn, :species), source: source) }
    let!(:genus1) { Protonym.create(name: 'Genus', parent_id: genus.parent_id, rank_class: Ranks.lookup(:icn, :genus)) }
    let!(:species1) { Protonym.create(name: 'aus', verbatim_author: 'Sidorov', parent: genus, rank_class: Ranks.lookup(:icn, :species)) }

    specify 'simple author' do
      expect(species.cached_author_year).to eq('Ivanov')
    end

    specify 'original combination' do
      species.original_genus = genus
      species.original_species = species
      species.save
      expect(species.cached_author_year).to eq('Ivanov')
    end

    specify 'subsequent combination' do
      species.original_genus = genus1
      species.original_species = species
      c = Combination.create(genus_id: genus.id, species_id: species.id, verbatim_author: 'Petrov')
      TaxonNameRelationship::CurrentCombination.create(subject_taxon_name: c, object_taxon_name: species)
      species.save
      expect(species.cached_author_year).to eq('(Ivanov) Petrov')
      TaxonNameRelationship::Icn::Unaccepting::OriginallyInvalid.create(subject_taxon_name: species1, object_taxon_name: species)
      species.save
      expect(species.cached_author_year).to eq('(Sidorov ex Ivanov) Petrov')
    end


  end
end
