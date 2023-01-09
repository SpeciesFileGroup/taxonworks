require 'rails_helper'

describe Queries::TaxonName::Filter, type: :model, group: [:nomenclature] do

  let!(:query) { Queries::TaxonName::Filter.new({}) }

  let(:root) { FactoryBot.create(:root_taxon_name)}
  let(:genus) { Protonym.create!(name: 'Erasmoneura', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
  let(:original_genus) { Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
  let!(:species) { Protonym.create!(
    name: 'vulnerata',
    rank_class: Ranks.lookup(:iczn, 'species'),
    parent: genus,
    original_genus: original_genus,
    verbatim_author: 'Fitch & Say',
    year_of_publication: 1800) }

  specify '#not_specified 1' do
    query.not_specified = false
    species.update!(parent: root, original_genus: nil)
    expect(query.all.map(&:id)).to_not include(species.id)
  end

  specify '#not_specified' do
    query.not_specified = true
    species.update!(parent: root, original_genus: nil)
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  specify '#parent_id[] 1' do
    query.parent_id = [genus.id, root.id]
    expect(query.all.map(&:id)).to contain_exactly(species.id, genus.id, original_genus.id)
  end

  specify '#taxon_name_type 1' do
    query.taxon_name_type = 'Combination'
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#taxon_name_type 2' do
    query.taxon_name_type = 'Protonym'
    expect(query.all.map(&:id)).to contain_exactly(root.id, genus.id, original_genus.id, species.id)
  end

  specify '#taxon_name_relationship_type 1' do
    a = TaxonNameRelationship::Iczn::Invalidating
    a.create!(subject_taxon_name: genus, object_taxon_name: original_genus)
    query.taxon_name_relationship_type = [ a.to_s ]
    expect(query.all.map(&:id)).to contain_exactly(genus.id, original_genus.id)
  end

  specify '#leaves 1' do
    query.leaves = true
    expect(query.all.map(&:id)).to contain_exactly(species.id, original_genus.id)
  end

  specify '#leaves 2' do
    query.leaves = false
    expect(query.all.map(&:id)).to contain_exactly(genus.id, root.id)
  end

  specify '#nomenclature_group 1' do
    query.nomenclature_group = 'Species'
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  specify '#nomenclature_code 1' do
    query.nomenclature_group = 'Icnb'
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#nomenclature_code 2' do
    query.nomenclature_group = 'Iczn'
    expect(query.all.map(&:id).size).to eq(3) # Root has no rank!
  end

  specify '#citations 1' do
    query.citations = false
    expect(query.all.map(&:id).size).to eq(4)
  end

  specify '#citations 2' do
    query.citations = false
    Citation.create!(citation_object: species, source: FactoryBot.create(:valid_source))
    expect(query.all.map(&:id).size).to eq(3)
  end

  specify '#citations 3' do
    query.origin_citation = false
    Citation.create!(citation_object: species, source: FactoryBot.create(:valid_source))
    expect(query.all.map(&:id).size).to eq(4)
  end

  specify '#citations 4' do
    query.origin_citation = false
    Citation.create!(citation_object: species, is_original: true, source: FactoryBot.create(:valid_source))
    expect(query.all.map(&:id).size).to eq(3)
  end

  specify '#otus 1' do
    query.otus = true
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#otus 2' do
    Otu.create!(taxon_name: species)
    query.otus = true
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  specify '#authors 1' do
    query.authors = true
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  specify '#type_metadata 1' do
    query.type_metadata = true
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#type_metadata 2' do
    query.type_metadata = false
    expect(query.all.map(&:id).size).to eq(4)
  end

  specify '#type_metadata 3' do
    query.type_metadata = true
    query.name = species.name
    TypeMaterial.create!(protonym: species, type_type: 'holotype', collection_object:  FactoryBot.create(:valid_specimen))
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  specify '#type_metadata 4' do
    query.type_metadata = false
    TypeMaterial.create!(protonym: species, type_type: 'holotype', collection_object:  FactoryBot.create(:valid_specimen))
    expect(query.all.map(&:id)).to contain_exactly(root.id, genus.id, original_genus.id)
  end

  specify '#taxon_name_classification[]' do
    TaxonNameClassification::Iczn::Available.create!(taxon_name: genus)
    query.taxon_name_classification = [ 'TaxonNameClassification::Iczn::Available' ]
    expect(query.all.map(&:id)).to contain_exactly(genus.id)
  end

  specify '#combination_taxon_name_id[] ' do
    g = Protonym.create!(name: 'Era', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)
    a = Combination.create!(genus: g, species: species)
    b = Combination.create!(genus: original_genus)
    query.combination_taxon_name_id = [species.id]
    expect(query.all.map(&:id)).to contain_exactly(a.id)
  end

  specify '#taxon_name_relationship[] 0' do
    g = Protonym.create!(name: 'Era', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)
    a = Combination.create!(genus: g, species: species)

    query.taxon_name_type = 'Combination'
    query.taxon_name_relationship = [ { 'subject_taxon_name_id' => species.id.to_s, 'type' => 'TaxonNameRelationship::Combination::Species' } ]
    expect(query.all.map(&:id)).to contain_exactly(a.id)
  end


  specify '#taxon_name_relationship[] 1' do
    query.taxon_name_relationship = [ { 'subject_taxon_name_id' => genus.id.to_s, 'type' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling' } ]
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#taxon_name_relationship[] 2' do
    TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create!(subject_taxon_name_id: genus.id, object_taxon_name_id: original_genus.id)
    query.taxon_name_relationship = [ { 'subject_taxon_name_id' => genus.id.to_s, 'type' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling' } ]
    expect(query.all.map(&:id)).to contain_exactly(original_genus.id)
  end

  specify '#taxon_name_relationship[] 3' do
    TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create!(subject_taxon_name_id: original_genus.id, object_taxon_name_id: genus.id)
    query.taxon_name_relationship = [ { 'subject_taxon_name_id' => original_genus.id.to_s, 'type' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling' } ]
    expect(query.all.map(&:id)).to contain_exactly(genus.id)
  end

  specify '#taxon_name_relationship[] 4' do
    TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create!(object_taxon_name_id: genus.id, subject_taxon_name_id: original_genus.id)
    query.taxon_name_relationship = [ { 'object_taxon_name_id' => genus.id.to_s, 'type' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling' } ]
    expect(query.all.map(&:id)).to contain_exactly(original_genus.id)
  end

  specify '#taxon_name_relationship[] 5' do
    TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create!(object_taxon_name_id: original_genus.id, subject_taxon_name_id: genus.id)
    query.taxon_name_relationship = [ { 'object_taxon_name_id' => original_genus.id.to_s, 'type' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling' } ]
    expect(query.all.map(&:id)).to contain_exactly(genus.id)
  end

  specify '#taxon_name_relationship[] 6' do
    TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create!(subject_taxon_name_id: genus.id, object_taxon_name_id: original_genus.id)
    TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName.create!(subject_taxon_name_id: original_genus.id, object_taxon_name_id: genus.id)

    query.taxon_name_relationship = [
      { 'subject_taxon_name_id' => original_genus.id.to_s, 'type' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName' },
      { 'object_taxon_name_id' => original_genus.id.to_s, 'type' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling' } ]
    expect(query.all.map(&:id)).to contain_exactly(genus.id)
  end

  specify '#taxon_name_id[]' do
    query.taxon_name_id = [root.id]
    expect(query.all.map(&:id)).to contain_exactly(root.id)
  end

  specify '#taxon_name_id[] 2' do
    query.taxon_name_id = [genus.id]
    query.descendants = true
    expect(query.all.map(&:id)).to contain_exactly(species.id, genus.id)
  end

  specify '#taxon_name_id[] 3' do
    query.taxon_name_id = [species.id]
    query.ancestors = true
    expect(query.all.map(&:id)).to contain_exactly(species.id, genus.id, root.id)
  end

  specify '#taxon_name_id[] 4' do
    query.taxon_name_id = [species.id]
    query.ancestors = true
    query.nomenclature_group = 'Genus'
    expect(query.all.map(&:id)).to contain_exactly(genus.id)
  end

  specify '#taxon_name_id[] 5' do
    query.taxon_name_id = [genus.id]
    query.ancestors = true
    query.descendants = true
    expect(query.all.map(&:id)).to contain_exactly(genus.id)
  end

  specify '#taxon_name_id[] 4' do
    query.taxon_name_id = [species.id]
    query.ancestors = true
    expect(query.all.map(&:id)).to contain_exactly(species.id, genus.id, root.id)
  end

  specify '#name' do
    query.name = 'vulner'
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  specify '#name, #exact' do
    query.name = 'vulnerata'
    query.exact = true
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#author' do
    query.author = 'Fitch & S'
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  specify '#author, #exact' do
    query.author = 'Fit'
    query.exact = true
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#year' do
    query.year = 1800
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  # TODO: deprecate for User concern
  specify '#updated_since' do
    species.update!(updated_at: '2050/1/1')
    query.updated_since = '2049-12-01'
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  specify '#validity 1' do
    query.validity = true
    expect(query.all.map(&:id).size).to eq(4)
  end

  specify '#validity 2' do
    query.validity = false
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify 'all filters combined' do
    Citation.create!(citation_object: species, source: FactoryBot.create(:valid_source))
    Otu.create!(taxon_name: species)
    TypeMaterial.create!(protonym: species, type_type: 'holotype', collection_object: FactoryBot.create(:valid_specimen))
    TaxonNameClassification::Iczn::Available.create!(taxon_name: species)
    TaxonNameRelationship::Typification::Genus.create!(subject_taxon_name_id: species.id, object_taxon_name_id: genus.id)
    species.update!(updated_at: '2050/1/1')

    query.nomenclature_group = 'Species'
    query.nomenclature_group = 'Iczn'
    query.citations = 'without_origin_citation'
    query.otus = true
    query.authors = true
    query.type_metadata = true
    query.taxon_name_classification = [ 'TaxonNameClassification::Iczn::Available' ]
    query.taxon_name_relationship = [ { 'object_taxon_name_id' => genus.id.to_s, 'type' => 'TaxonNameRelationship::Typification::Genus' } ]
    query.taxon_name_id = [species.id]
    query.name = 'Erasmoneura vulnerata'
    query.author = '(Fitch & Say, 1800)'
    query.exact = true
    query.year = 1800
    query.updated_since = '2049-12-01'
    query.validity = true
    query.leaves = true
    query.taxon_name_type = 'Protonym'

    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

end
