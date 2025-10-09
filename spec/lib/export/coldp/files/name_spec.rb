require 'rails_helper'

describe Export::Coldp::Files::Name, type: :model, group: :col do

  # In
  let(:root_taxon_name) { FactoryBot.create(:root_taxon_name) }
  let!(:family) { Protonym.create!(rank_class: Ranks.lookup(:iczn, :family), name: 'Goodidae', parent: root_taxon_name) }
  let!(:original_genus) { Protonym.create!(rank_class: Ranks.lookup(:iczn, :genus), name: 'Ous', parent: family) }
  let!(:genus) { Protonym.create!(rank_class: Ranks.lookup(:iczn, :genus), name: 'Aus', parent: family) }
  let!(:genus2) { Protonym.create!(rank_class: Ranks.lookup(:iczn, :genus), name: 'Bus', parent: family) }
  let!(:species) { Protonym.create!(rank_class: Ranks.lookup(:iczn, :species), name: 'cus', parent: genus, original_genus:, verbatim_author: 'Smith', year_of_publication: 2000) }
  let!(:synonymous_species) { Protonym.create!(rank_class: Ranks.lookup(:iczn, :species), name: 'cus', parent: genus, verbatim_author: 'Jones', year_of_publication: 2002) }

  # Second scope
  let!(:combination) { Combination.create!(species: synonymous_species, genus: genus2 ) }

  # Out
  let!(:bad_nominotypical_family) { Protonym.create!(rank_class: Ranks.lookup(:iczn, :subfamily), name: 'Goodinae', parent: root_taxon_name) }

  let!(:synonymy) { TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(subject_taxon_name: synonymous_species, object_taxon_name: species) }
  let!(:family_synonymy) { TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm.create!(subject_taxon_name: bad_nominotypical_family, object_taxon_name: family) }

  let!(:otu) { Otu.create!(taxon_name: root_taxon_name) }

  specify 'invalid test' do
    expect(bad_nominotypical_family.cached_is_valid).to eq(false)
  end

  specify '#core_names' do
    q = Export::Coldp::Files::Name.core_names(otu)
    expect(q.all.length).to eq(4) # Subfamily if invalid properly will be excluded # Why size doesn't work
  end

  specify '#core names excludes invalid nominotypical families' do
    q = Export::Coldp::Files::Name.core_names(otu)
    expect(q.all).to_not include(bad_nominotypical_family)
  end

  specify '#core names do not include invalid names' do
    q = Export::Coldp::Files::Name.core_names(otu)
    expect(q.all).to_not include(synonymous_species)
  end

  specify '#core names do not include Combination names' do
    q = Export::Coldp::Files::Name.core_names(otu)
    expect(q.all).to_not include(combination)
  end

  # testing inferred combinations
  
end

describe Export::Coldp::Files::Name, type: :model, group: :col do
  let(:root_taxon_name) { FactoryBot.create(:root_taxon_name) }

  let!(:family) {
    Protonym.create!(
      rank_class: Ranks.lookup(:iczn, :family),
      name: 'Goodidae',
      parent: root_taxon_name
    )
  }

  let!(:genus3) {
    Protonym.create!(
      rank_class: Ranks.lookup(:iczn, :genus),
      name: 'Phalangium',
      parent: family,
      cached_gender: 'neuter'
    )
  }

  let!(:tnc_genus3) {
    TaxonNameClassification.create!(
      taxon_name: genus3,
      type: 'TaxonNameClassification::Latinized::Gender::Neuter'
    )
  }

  let!(:species3) {
    Protonym.create!(
      rank_class: Ranks.lookup(:iczn, :species),
      name: 'opilio',
      parent: genus3,
      verbatim_author: 'Linnaeus',
      year_of_publication: 1758
    )
  }

  let!(:tnc_species3) {
    TaxonNameClassification.create!(
      taxon_name: species3,
      type: 'TaxonNameClassification::Latinized::PartOfSpeech::NounInApposition'
    )
  }

  let!(:otu1) { Otu.create!(taxon_name: family) }
  let!(:otu2) { Otu.create!(taxon_name: genus3) }
  let!(:otu3) { Otu.create!(taxon_name: species3) }

  let!(:genus4) {
    Protonym.create!(
      rank_class: Ranks.lookup(:iczn, :genus),
      name: 'Cerastoma',
      parent: family,
      cached_gender: 'neuter'
    )
  }

  let!(:tnc_genus4) {
    TaxonNameClassification.create!(
      taxon_name: genus4,
      type: 'TaxonNameClassification::Latinized::Gender::Neuter'
    )
  }

  let!(:species4) {
    Protonym.create!(
      rank_class: Ranks.lookup(:iczn, :species),
      name: 'brevicornis',
      parent: genus4,
      verbatim_author: 'Koch',
      year_of_publication: 1839
    )
  }

  let!(:original_genus) {
    TaxonNameRelationship.create!(
      type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
      object_taxon_name: species4,
      subject_taxon_name: genus4
    )
  }

  let!(:original_species) {
    TaxonNameRelationship.create!(
      type: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies',
      object_taxon_name: species4,
      subject_taxon_name: species4
    )
  }

  let!(:tnc_species4) {
    TaxonNameClassification.create!(
      taxon_name: species4,
      type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective'
    )
  }

  let!(:synonymy) {
    TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
      subject_taxon_name: species4,
      object_taxon_name: species3
    )
  }

  let!(:combination) {
    Combination.create!(
      genus: genus3,
      species: species4
    )
  }

  let!(:otu) { Otu.create!(taxon_name: root_taxon_name) }

  specify 'Cerastoma brevicornis Koch, 1839 is present' do
    names = Export::Coldp::Files::Name.core_names(otu).map(&:cached)
    expect(names).to include('Cerastoma brevicornis')
  end

  specify 'Phalangium brevicorne (Koch, 1839) is present' do
    names = Export::Coldp::Files::Name.core_names(otu).map(&:cached)
    expect(names).to include('Phalangium brevicorne')
  end

  specify 'Phalangium opilio Linnaeus, 1758 is present' do
    names = Export::Coldp::Files::Name.core_names(otu).map(&:cached)
    expect(names).to include('Phalangium opilio')
  end
end