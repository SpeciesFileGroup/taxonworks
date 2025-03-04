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
    expect(q.all.length).to eq(8) # Subfamily if invalid properly will be excluded # Why size doesn't work
  end

  specify '#core names excludes invalid nominotypical families' do
    q = Export::Coldp::Files::Name.core_names(otu)
    expect(q.all).to_not include(bad_nominotypical_family)
  end

  specify '#core names includes invalid names' do
    q = Export::Coldp::Files::Name.core_names(otu)
    expect(q.all).to include(synonymous_species)
  end

  specify '#core names includes Combination names' do
    q = Export::Coldp::Files::Name.core_names(otu)
    expect(q.all).to include(combination)
  end

end
