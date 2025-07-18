require 'rails_helper'

describe Queries::TaxonName::Filter, type: :model, group: [:nomenclature] do
  let!(:query) { Queries::TaxonName::Filter.new({}) }

  let(:root) { FactoryBot.create(:root_taxon_name) }
  let(:genus) { Protonym.create!(name: 'Erasmoneura', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
  let(:original_genus) { Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
  let!(:species) {
    Protonym.create!(
      name: 'vulnerata',
      rank_class: Ranks.lookup(:iczn, 'species'),
      parent: genus,
      original_genus: original_genus,
      verbatim_author: 'Fitch & Say',
      year_of_publication: 1800,
    )
  }

  specify '#combinations intersect with other queries in legal SQL' do
    query.combinations = false
    query.taxon_name_id = genus.id
    query.descendants = true
    expect(query.all.to_a).to be_truthy
  end

  specify '#verbatim_name without' do
    query.verbatim_name = false
    expect(query.all).to include(species, genus, original_genus, root)
  end

  specify '#verbatim_name with' do
    query.verbatim_name = true
    expect(query.all).to be_empty
  end

  specify '#verbatim_name with 2' do
    genus.update!(verbatim_name: 'Foo')
    query.verbatim_name = true
    expect(query.all).to include(genus)
  end

  context '#ancestrify' do
    let!(:s_no) {
      Protonym.create!(
        name: 'nox',
        rank_class: Ranks.lookup(:iczn, 'species'),
        parent: genus,
      )
    }

    let!(:g_no) {
      Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)
    }

    specify 'basic' do
      query.ancestrify = true
      query.taxon_name_id = species.id

      expect(query.all.map(&:id)).to include(species.id, genus.id, root.id)
    end

    specify 'not cross project' do
      p2 = FactoryBot.create(:valid_project)

      a = Protonym.create!(
        name: 'notme',
        rank_class: Ranks.lookup(:iczn, 'species'),
        parent: p2.root_taxon_name,
        project: p2
      )

      query.ancestrify = true
      query.taxon_name_id = species.id

      expect(query.all.map(&:id)).to_not include(a.id)
    end
  end

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

  context '#taxon_name_relationship_type with subject/object/any' do
    specify '#taxon_name_relationship_type 1' do
      a = TaxonNameRelationship::Iczn::Invalidating
      a.create!(subject_taxon_name: genus, object_taxon_name: original_genus)
      query.taxon_name_relationship_type_either = [a.to_s]
      expect(query.all.map(&:id)).to contain_exactly(genus.id, original_genus.id)
    end

    context 'with duplicates' do
      let(:other_genus) {
        Protonym.create!(name: 'Cus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)
      }
      before(:each) do
        TaxonNameRelationship::Typification::Genus.create!(
          subject_taxon_name_id: species.id,
          object_taxon_name_id: genus.id
        )
        # Create more relations that duplicate existing subject/object so that
        # we check we're not returning duplicates.
        TaxonNameRelationship::Typification::Genus.create!(
          subject_taxon_name_id: species.id,
          object_taxon_name_id: original_genus.id
        )

        TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create!(
          subject_taxon_name_id: original_genus.id,
          object_taxon_name_id: genus.id
        )
        TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create!(
          subject_taxon_name_id: other_genus.id,
          object_taxon_name_id: genus.id
        )
      end

      specify 'subject' do
        query.taxon_name_relationship_type_subject =
          'TaxonNameRelationship::Typification::Genus'
        expect(query.all.map(&:id)).to contain_exactly(species.id)
      end

      specify 'multiple subject' do
        query.taxon_name_relationship_type_subject = [
          'TaxonNameRelationship::Typification::Genus',
          'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling'
        ]
        expect(query.all.map(&:id))
          .to contain_exactly(species.id, original_genus.id, other_genus.id)
      end

      specify 'object' do
        query.taxon_name_relationship_type_object =
          'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling'
        expect(query.all.map(&:id)).to contain_exactly(genus.id)
      end

      specify 'either' do
        query.taxon_name_relationship_type_either =
          'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling'
        expect(query.all.map(&:id))
          .to contain_exactly(genus.id, other_genus.id, original_genus.id)
      end

      specify 'subject and object' do
        query.taxon_name_relationship_type_subject =
          'TaxonNameRelationship::Typification::Genus'
        query.taxon_name_relationship_type_object =
          'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling'
        expect(query.all.map(&:id)).to contain_exactly(species.id, genus.id)
      end
    end
  end

  specify '#leaves 1' do
    query.leaves = true
    expect(query.all.map(&:id)).to contain_exactly(species.id, original_genus.id)
  end

  specify '#leaves 2' do
    query.leaves = false
    expect(query.all.map(&:id)).to contain_exactly(genus.id, root.id)
  end

  context '#latinized' do
    let!(:fem_genus) {
      g = Protonym.create!(name: 'Rosa',
        rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)
      TaxonNameClassification::Latinized::Gender::Feminine.create!(taxon_name: g)
      g
    }

    let!(:fem_species) {
      s = Protonym.create!(
        name: 'blanda',
        rank_class: Ranks.lookup(:iczn, 'species'),
        parent: fem_genus
      )
      TaxonNameClassification::Latinized::PartOfSpeech::Adjective.create!(taxon_name: s)
      s
    }

    specify '#latinized true' do
      query.latinized = true
      expect(query.all.map(&:id)).to contain_exactly(
        fem_genus.id, fem_species.id
      )
    end

    specify '#latinized false' do
      query.latinized = false
      expect(query.all.map(&:id)).to contain_exactly(
        genus.id, original_genus.id, species.id
      )
    end
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
    TypeMaterial.create!(protonym: species, type_type: 'holotype', collection_object: FactoryBot.create(:valid_specimen))
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  specify '#type_metadata 4' do
    query.type_metadata = false
    TypeMaterial.create!(protonym: species, type_type: 'holotype', collection_object: FactoryBot.create(:valid_specimen))
    expect(query.all.map(&:id)).to contain_exactly(root.id, genus.id, original_genus.id)
  end

  specify '#taxon_name_classification[]' do
    TaxonNameClassification::Iczn::Available.create!(taxon_name: genus)
    query.taxon_name_classification = ['TaxonNameClassification::Iczn::Available']
    expect(query.all.map(&:id)).to contain_exactly(genus.id)
  end

  specify '#combination_taxon_name_id[] ' do
    g = Protonym.create!(name: 'Era', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)
    a = Combination.create!(genus: g, species: species)
    b = Combination.create!(genus: original_genus)
    query.combination_taxon_name_id = [species.id]
    expect(query.all.map(&:id)).to contain_exactly(a.id)
  end

  context '#taxon_name_relationship_target' do
    before(:each) do
      TaxonNameRelationship::Typification::Genus.create!(
        subject_taxon_name_id: species.id, object_taxon_name_id: genus.id
      )
    end

    let!(:tnr_query) {
      ::TaxonNameRelationship.where(type:
        'TaxonNameRelationship::Typification::Genus'
      )
    }

    specify 'subject' do
      query.taxon_name_relationship_query = tnr_query
      query.taxon_name_relationship_target = 'subject'
      expect(query.all.map(&:id)).to contain_exactly(species.id)
    end

    specify 'object' do
      query.taxon_name_relationship_query = tnr_query
      query.taxon_name_relationship_target = 'object'
      expect(query.all.map(&:id)).to contain_exactly(genus.id)
    end

    specify 'both' do
      query.taxon_name_relationship_query = tnr_query
      query.taxon_name_relationship_target = nil
      expect(query.all.map(&:id)).to contain_exactly(genus.id, species.id)
    end
  end

  context '#relationToRelationship' do
    before(:each) do
      # There's already an OriginalCombination::OriginalGenus
      # 'original_genus -> species' relationship as well.
      TaxonNameRelationship::Typification::Genus.create!(
        subject_taxon_name_id: species.id, object_taxon_name_id: genus.id
      )
      # Create more relations that duplicate existing subject/object so that we
      # check we're not returning duplicates.
      TaxonNameRelationship::Typification::Genus.create!(
        subject_taxon_name_id: species.id, object_taxon_name_id: original_genus.id
      )
      TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create!(
        subject_taxon_name_id: original_genus.id, object_taxon_name_id: genus.id
      )
    end

    specify 'subject' do
      query.relation_to_relationship = 'subject'
      expect(query.all.map(&:id))
        .to contain_exactly(species.id, original_genus.id)
    end

    specify 'object' do
      query.relation_to_relationship = 'object'
      expect(query.all.map(&:id))
        .to contain_exactly(genus.id, species.id, original_genus.id)
    end

    specify 'either' do
      query.relation_to_relationship = 'either'
      expect(query.all.map(&:id))
        .to contain_exactly(species.id, genus.id, original_genus.id)
    end
  end

  specify '#taxon_name_relationship[] 0' do
    g = Protonym.create!(name: 'Era', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root)
    a = Combination.create!(genus: g, species: species)

    query.taxon_name_type = 'Combination'
    query.taxon_name_relationship = [{ 'subject_taxon_name_id' => species.id.to_s, 'type' => 'TaxonNameRelationship::Combination::Species' }]
    expect(query.all.map(&:id)).to contain_exactly(a.id)
  end

  specify '#taxon_name_relationship[] 1' do
    query.taxon_name_relationship = [{ 'subject_taxon_name_id' => genus.id.to_s, 'type' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling' }]
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#taxon_name_relationship[] 2' do
    TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create!(subject_taxon_name_id: genus.id, object_taxon_name_id: original_genus.id)
    query.taxon_name_relationship = [{ 'subject_taxon_name_id' => genus.id.to_s, 'type' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling' }]
    expect(query.all.map(&:id)).to contain_exactly(original_genus.id)
  end

  specify '#taxon_name_relationship[] 3' do
    TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create!(subject_taxon_name_id: original_genus.id, object_taxon_name_id: genus.id)
    query.taxon_name_relationship = [{ 'subject_taxon_name_id' => original_genus.id.to_s, 'type' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling' }]
    expect(query.all.map(&:id)).to contain_exactly(genus.id)
  end

  specify '#taxon_name_relationship[] 4' do
    TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create!(object_taxon_name_id: genus.id, subject_taxon_name_id: original_genus.id)
    query.taxon_name_relationship = [{ 'object_taxon_name_id' => genus.id.to_s, 'type' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling' }]
    expect(query.all.map(&:id)).to contain_exactly(original_genus.id)
  end

  specify '#taxon_name_relationship[] 5' do
    TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create!(object_taxon_name_id: original_genus.id, subject_taxon_name_id: genus.id)
    query.taxon_name_relationship = [{ 'object_taxon_name_id' => original_genus.id.to_s, 'type' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling' }]
    expect(query.all.map(&:id)).to contain_exactly(genus.id)
  end

  specify '#taxon_name_relationship[] 6' do
    TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create!(subject_taxon_name_id: genus.id, object_taxon_name_id: original_genus.id)
    TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName.create!(subject_taxon_name_id: original_genus.id, object_taxon_name_id: genus.id)

    query.taxon_name_relationship = [
      { 'subject_taxon_name_id' => original_genus.id.to_s, 'type' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName' },
      { 'object_taxon_name_id' => original_genus.id.to_s, 'type' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling' },
    ]
    expect(query.all.map(&:id)).to contain_exactly(genus.id)
  end

  specify '#taxon_name_id[]' do
    query.taxon_name_id = [root.id]
    expect(query.all.map(&:id)).to contain_exactly(root.id)
  end

  specify '#taxon_name_id[] 2 #descendants' do
    query.taxon_name_id = [genus.id]
    query.descendants = true # only descendants
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  specify '#taxon_name_id[] 2 #descendants' do
    query.taxon_name_id = [genus.id]
    query.descendants = false # self and descendants
    expect(query.all.map(&:id)).to contain_exactly(species.id, genus.id)
  end

  specify '#combinationify' do
    combination = Combination.create!(genus:, species:)
    query.taxon_name_id = [genus.id]
    query.descendants = true # not self
    query.combinationify = true
    expect(query.all.map(&:id)).to contain_exactly(species.id, combination.id)
  end

  specify '#combinationify' do
    combination = Combination.create!(genus:, species:)
    query.taxon_name_id = [genus.id]
    query.descendants = false
    query.combinationify = true
    expect(query.all.map(&:id)).to contain_exactly(species.id, genus.id, combination.id)
  end

  specify '#taxon_name_id[] 2.2' do
    species1 = Protonym.create!(
      name: 'atra',
      rank_class: Ranks.lookup(:iczn, 'species'),
      parent: genus,
      original_genus: original_genus,
      verbatim_author: 'Fitch & Say',
      year_of_publication: 1800,
    )
    tr = TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name_id: species1.id, object_taxon_name_id: species.id)

    query.taxon_name_id = [genus.id]
    query.descendants = true
    expect(query.all.map(&:id)).to contain_exactly(species.id, species1.id)
  end

  specify '#taxon_name_id[] 2.2' do
    species1 = Protonym.create!(
      name: 'atra',
      rank_class: Ranks.lookup(:iczn, 'species'),
      parent: genus,
      original_genus: original_genus,
      verbatim_author: 'Fitch & Say',
      year_of_publication: 1800,
    )
    tr = TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name_id: species1.id, object_taxon_name_id: species.id)

    query.taxon_name_id = [genus.id]
    query.descendants = false
    expect(query.all.map(&:id)).to contain_exactly(species.id, genus.id, species1.id)
  end

  specify '#synonymify 1' do
    genus1 = Protonym.create!(
      name: 'Genus',
      rank_class: Ranks.lookup(:iczn, 'genus'),
      parent_id: genus.parent_id,
    )
    tr = TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name_id: genus1.id, object_taxon_name_id: genus.id)
    query.taxon_name_id = [genus.id]
    query.descendants = true
    query.synonymify = true
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  specify '#synonymify 2' do
    genus1 = Protonym.create!(
      name: 'Genus',
      rank_class: Ranks.lookup(:iczn, 'genus'),
      parent_id: genus.parent_id,
    )
    tr = TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name_id: genus1.id, object_taxon_name_id: genus.id)
    query.taxon_name_id = [genus.id]
    query.descendants = false
    query.synonymify = true
    expect(query.all.map(&:id)).to contain_exactly(species.id, genus.id, genus1.id)
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
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#taxon_name_id[] 5' do
    query.taxon_name_id = [genus.id]
    query.ancestors = true
    query.descendants = false
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

  specify '#name, #name_exact' do
    query.name = 'vulnerata'
    query.name_exact = true
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#author' do
    query.author = 'Fitch & S'
    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end

  specify '#author, #author_exact' do
    query.author = 'Fit'
    query.author_exact = true
    expect(query.all.map(&:id)).to contain_exactly()
  end

  specify '#year' do
    query.year = 1800
    expect(query.all).to contain_exactly(species)
  end

  specify '#year_start' do
    query.year_start = 1800
    expect(query.all).to contain_exactly(species)
  end

  specify '#year_end' do
    query.year_end = 1800
    expect(query.all).to contain_exactly(species)
  end

  specify '#year_start, #year_end' do
    query.year_start = 1798
    query.year_end = 1799
    expect(query.all.map(&:id)).to contain_exactly()
  end

  # From User concern
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
    query.taxon_name_classification = ['TaxonNameClassification::Iczn::Available']
    query.taxon_name_relationship = [{ 'object_taxon_name_id' => genus.id.to_s, 'type' => 'TaxonNameRelationship::Typification::Genus' }]
    query.taxon_name_id = [species.id]
    query.name = 'Erasmoneura vulnerata'
    query.author = '(Fitch & Say, 1800)'
    query.name_exact = true
    query.year = 1800
    query.updated_since = '2049-12-01'
    query.validity = true
    query.leaves = true
    query.taxon_name_type = 'Protonym'

    expect(query.all.map(&:id)).to contain_exactly(species.id)
  end
end
