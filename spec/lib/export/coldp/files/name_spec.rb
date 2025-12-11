require 'rails_helper'

describe Export::Coldp::Files::Name, type: :model, group: :col do

  context 'basic setup' do
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
  end


   context 'test invalid original combination with matching gender' do


    let(:root_taxon_name) { FactoryBot.create(:root_taxon_name) }

    let!(:family) {
      Protonym.create!(
        rank_class: Ranks.lookup(:iczn, :family),
        name: 'Goodidae',
        parent: root_taxon_name
      )
    }

    let!(:genus_phalangium) {
      Protonym.create!(
        rank_class: Ranks.lookup(:iczn, :genus),
        name: 'Phalangium',
        parent: family,
      )
    }

    let!(:tnc_genus_phalangium) {
      TaxonNameClassification::Latinized::Gender::Neuter.create!( taxon_name: genus_phalangium )
    }

    let!(:accepted_species_opilio) {
      Protonym.create!(
        rank_class: Ranks.lookup(:iczn, :species),
        name: 'opilio',
        parent: genus_phalangium,
        verbatim_author: 'Linnaeus',
        year_of_publication: 1758
      )
    }
    
    let!(:tnc_accepted_species_opilio) {
      TaxonNameClassification::Latinized::PartOfSpeech::NounInApposition.create!(
        taxon_name: accepted_species_opilio
      )
    }

    let!(:otu1) { Otu.create!(taxon_name: family) }
    let!(:otu2) { Otu.create!(taxon_name: genus_phalangium) }
    let!(:otu3) { Otu.create!(taxon_name: accepted_species_opilio) }

    let!(:genus_cerastoma) {
      Protonym.create!(
        rank_class: Ranks.lookup(:iczn, :genus),
        name: 'Cerastoma',
        parent: family
      )
    }

    let!(:tnr_genus_cerastoma) {
      TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective.create!( subject_taxon_name: genus_cerastoma, object_taxon_name: genus_phalangium )
    }

    let!(:tnc_genus_cerastoma) {
      TaxonNameClassification::Latinized::Gender::Neuter.create!( taxon_name: genus_cerastoma )
    }

    let!(:synonym_species_dentatum) {
      Protonym.create!(
        rank_class: Ranks.lookup(:iczn, :species),
        name: 'dentatum',

        masculine_name: 'dentatus',
        feminine_name: 'dentata',
        neuter_name: 'dentatum',

        parent: genus_phalangium,
        verbatim_author: 'Koch',
        year_of_publication: 1871
      )
    }

    let!(:original_genus) {
      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(
        object_taxon_name: synonym_species_dentatum,
        subject_taxon_name: genus_cerastoma
      )
    }

    let!(:original_species) {
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(
        object_taxon_name: synonym_species_dentatum,
        subject_taxon_name: synonym_species_dentatum
      )
    }

    let!(:tnc_synonym_species_dentatum) {
      TaxonNameClassification::Latinized::PartOfSpeech::Adjective.create!(taxon_name: synonym_species_dentatum)
    }

    let!(:synonymy) {
      TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective.create!(
        subject_taxon_name: synonym_species_dentatum,
        object_taxon_name: accepted_species_opilio
      )
    }

    let!(:combination) {
      Combination.create!(
        genus: genus_phalangium,
        species: synonym_species_dentatum
      )
    }

    let!(:otu) { Otu.create!(taxon_name: root_taxon_name) }

    # TODO: 
    #   * Ensure we have a original_combination_names test for an original combination of an invalid name
    #   * Check the status of a couple more missing original names- are they all the originals?

    specify 'Original combinaton Cerastoma dentatum Koch, 1871 is present' do
      names = Export::Coldp::Files::Name.original_combination_names(otu).map(&:cached)
      expect(names).to include('Cerastoma dentatum')
    end

    specify 'Synonym Phalangium dentatum (Koch, 1871) is present' do
      names = Export::Coldp::Files::Name.invalid_core_names(otu).map(&:cached)
      expect(names).to include('Phalangium dentatum')
    end

    specify 'Accepted Phalangium opilio Linnaeus, 1758 is present' do
      names = Export::Coldp::Files::Name.core_names(otu).map(&:cached)
      expect(names).to include('Phalangium opilio')
    end

    # TODO: Original combination is present

  end

  context 'edge case with invalid original combination with gender mismatches' do

    let(:root_taxon_name) { FactoryBot.create(:root_taxon_name) }

    let!(:family) {
      Protonym.create!(
        rank_class: Ranks.lookup(:iczn, :family),
        name: 'Goodidae',
        parent: root_taxon_name
      )
    }

    let!(:genus_phalangium) {
      Protonym.create!(
        rank_class: Ranks.lookup(:iczn, :genus),
        name: 'Phalangium',
        parent: family,
      )
    }

    let!(:tnc_genus_phalangium) {
      TaxonNameClassification::Latinized::Gender::Neuter.create!( taxon_name: genus_phalangium )
    }

    let!(:accepted_species_opilio) {
      Protonym.create!(
        rank_class: Ranks.lookup(:iczn, :species),
        name: 'opilio',
        parent: genus_phalangium,
        verbatim_author: 'Linnaeus',
        year_of_publication: 1758
      )
    }

    let!(:tnc_accepted_species_opilio) {
      TaxonNameClassification::Latinized::PartOfSpeech::NounInApposition.create!(
        taxon_name: accepted_species_opilio
      )
    }

    let!(:otu1) { Otu.create!(taxon_name: family) }
    let!(:otu2) { Otu.create!(taxon_name: genus_phalangium) }
    let!(:otu3) { Otu.create!(taxon_name: accepted_species_opilio) }

    let!(:genus_cerastoma) {
      Protonym.create!(
        rank_class: Ranks.lookup(:iczn, :genus),
        name: 'Cerastoma',
        parent: family
      )
    }

    let!(:tnr_genus_cerastoma) {
      TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective.create!(
        subject_taxon_name: genus_cerastoma,
        object_taxon_name: genus_phalangium
      )
    }

    let!(:tnc_genus_cerastoma) {
      TaxonNameClassification::Latinized::Gender::Neuter.create!( taxon_name: genus_cerastoma )
    }

    let!(:synonym_species_brevicorn) {
      Protonym.create!(
        rank_class: Ranks.lookup(:iczn, :species),
        name: 'brevicornis',
       
        masculine_name: 'brevicornis', 
        feminine_name: 'brevicornis',
        neuter_name: 'brevicorne',

        parent: genus_phalangium,
        verbatim_author: 'Koch',
        year_of_publication: 1839
      )
    }

    let!(:original_genus) {
      TaxonNameRelationship::OriginalCombination::OriginalGenus.create!(
        object_taxon_name: synonym_species_brevicorn,
        subject_taxon_name: genus_cerastoma
      )
    }

    let!(:original_species) {
      TaxonNameRelationship::OriginalCombination::OriginalSpecies.create!(
        object_taxon_name: synonym_species_brevicorn,
        subject_taxon_name: synonym_species_brevicorn
      )
    }

    let!(:tnc_synonym_species_brevicorn) {
      TaxonNameClassification::Latinized::PartOfSpeech::Adjective.create!(taxon_name: synonym_species_brevicorn)
    }

    let!(:synonymy) {
      TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective.create!(
        subject_taxon_name: synonym_species_brevicorn,
        object_taxon_name: accepted_species_opilio
      )
    }

    let!(:combination) {
      Combination.create!(
        genus: genus_phalangium,
        species: synonym_species_brevicorn
      )
    }

    let!(:otu) { Otu.create!(taxon_name: root_taxon_name) }

    # TODO: 
    #   * Ensure we have a original_combination_names test for an original combination of an invalid name
    #   * Check the status of a couple more missing original names- are they all the originals?

    specify 'Original combination Cerastoma brevicornis Koch, 1839 is present' do
      names = Export::Coldp::Files::Name.original_combination_names(otu).map(&:cached)
      expect(names).to include('Cerastoma brevicornis')
    end

    specify 'Synonym Phalangium brevicorne (Koch, 1839) is present' do
      names = Export::Coldp::Files::Name.invalid_core_names(otu).map(&:cached)
      expect(names).to include('Phalangium brevicorne')
    end

    specify 'Accepted Phalangium opilio Linnaeus, 1758 is present' do
      names = Export::Coldp::Files::Name.core_names(otu).map(&:cached)
      expect(names).to include('Phalangium opilio')
    end

    # TODO: Original combination is present

  end
end
