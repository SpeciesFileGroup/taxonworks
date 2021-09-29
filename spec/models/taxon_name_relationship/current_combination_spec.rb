require 'rails_helper'
describe TaxonNameRelationship::CurrentCombination, type: :model, group: [:nomenclature]  do
  let!(:root1) { FactoryBot.create(:root_taxon_name) }
  let!(:genus1) { Protonym.create(name: 'Aus', rank_class: Ranks.lookup(:icn, :genus), parent: root1) }
  let!(:genus2) { Protonym.create(name: 'Bus', rank_class: Ranks.lookup(:icn, :genus), parent: root1) }
  let!(:species1) { Protonym.create(name: 'ivanovi', rank_class: Ranks.lookup(:icn, :species), parent: genus1) }
  let!(:original_genus) { TaxonNameRelationship.create(subject_taxon_name: genus1, object_taxon_name: species1, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')}
  let!(:original_species) { TaxonNameRelationship.create(subject_taxon_name: species1, object_taxon_name: species1, type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies')}
  let!(:source1) { FactoryBot.create(:valid_source_bibtex, title: 'article 1', year: 1900, author: 'Ivanov, I.I.')}
  let!(:source2) { FactoryBot.create(:valid_source_bibtex, title: 'article 2', year: 2000, author: 'Petrov, P.P.')}
  let!(:person1) { Person.create(last_name: 'Ivanoff', first_name: 'Ivan I.') }
  let!(:person2) { Person.create(last_name: 'Petroff', first_name: 'Petr P.') }
  #  let!(:role1) { Role.new(person: person1, role_object: source1, type: 'SourceAuthor')}
  #  let!(:role2) { Role.new(person: person2, role_object: source2, type: 'SourceAuthor')}
  let!(:combination1) { FactoryBot.build(:combination, parent: genus1) }

  before do
    combination1.genus = genus2
    combination1.species = species1
    combination1.save
  end

  specify 'current combination is valid' do
    current_combination = TaxonNameRelationship.create(subject_taxon_name: combination1, object_taxon_name: species1, type: 'TaxonNameRelationship::CurrentCombination')
    expect(current_combination.id).to be_truthy
  end

  specify 'species author string' do
    species1.verbatim_author = 'Ivanov'
    species1.save
    expect(species1.cached_author_year).to eq('Ivanov')
  end

  specify 'species author source' do
    species1.source = source1
    species1.save
    expect(species1.cached_author_year).to eq('Ivanov')
  end

  specify 'species author source role' do
    role1 = Role.create(person: person1, role_object: source1, type: 'SourceAuthor')
    species1.source = source1
    species1.save
    expect(species1.cached_author_year).to eq('Ivanoff')
  end

  specify 'species author taxon_name role' do
    role1 = Role.create(person: person1, role_object: species1, type: 'TaxonNameAuthor')
    species1.source = source1
    species1.save
    expect(species1.cached_author_year).to eq('Ivanoff')
  end

  specify 'combination author string' do
    species1.verbatim_author = 'Ivanov'
    species1.save
    combination1.verbatim_author = 'Petrov'
    combination1.save
    expect(combination1.cached_author_year).to eq('(Ivanov) Petrov')
  end

  specify 'combination author source' do
    species1.source = source1
    species1.save
    combination1.source = source2
    combination1.save
    expect(combination1.cached_author_year).to eq('(Ivanov) Petrov')
  end

  specify 'species author current combination relationship' do
    role1 = Role.create(person: person1, role_object: species1, type: 'TaxonNameAuthor')
    role2 = Role.create(person: person2, role_object: combination1, type: 'TaxonNameAuthor')
    combination1.source = source2
    combination1.save
    current_combination = TaxonNameRelationship.create(subject_taxon_name: combination1, object_taxon_name: species1, type: 'TaxonNameRelationship::CurrentCombination')
    species1.source = source1
    species1.save
    expect(combination1.cached_author_year).to eq('(Ivanoff) Petroff')
    expect(species1.cached_author_year).to eq('(Ivanoff) Petroff')
    expect(species1.original_author_year).to eq('Ivanoff')
  end
end