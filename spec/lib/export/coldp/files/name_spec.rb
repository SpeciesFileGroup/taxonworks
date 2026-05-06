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

  # Reified original combination row for the species with an incomplete OC
  # (only OriginalGenus is set, no OriginalSpecies relationship). The protonym
  # has cached "Aus cus" but cached_original_combination "Ous cus" so it is reified
  # into a separate Name.tsv row. The reified species row must have empty uninomial, and the
  # genus / specificEpithet columns must hold the parsed parts.
  specify '#generate emits reified species OC with correct uninomial/genus/specificEpithet' do
    tsv = Export::Coldp::Files::Name.generate(otu, [])
    rows = CSV.parse(tsv, col_sep: "\t", headers: true)

    reified_row = rows.find { |r| r['scientificName'] == 'Ous cus' && r['rank'] == 'species' }

    expect(reified_row).not_to be_nil
    expect(reified_row['uninomial']).to be_nil.or eq('')
    expect(reified_row['genus']).to eq('Ous')
    expect(reified_row['specificEpithet']).to eq('cus')
  end

  # Reified OC row for a subspecies whose original combination is incomplete:
  # original_genus + original_species relations exist, but no
  # original_subspecies (self-referential) relation.
  #
  # The protonym under test is the subspecies 'minor':
  #   current  combination (cached):                      "Aus rufa minor"
  #   original combination (cached_original_combination): "Ous alba minor"
  # i.e. the OC differs from the current placement at both the genus and the
  # species level (a subspecies reclassified to a different species, in a
  # different genus, since publication).
  #
  # The reified row's atomized parts ("Ous", "alba") must come from the OC,
  # not from the current placement, and the protonym's own name ('minor')
  # must land in `infraspecificEpithet`. The pre-fix bug overwrote
  # `data['species']` with the protonym's name, producing genus="Ous",
  # specificEpithet="minor", infraspecificEpithet=nil, rank="species".
  specify '#generate handles incomplete subspecies OC (parent ranks preserved)' do
    original_species_alba = Protonym.create!(
      rank_class: Ranks.lookup(:iczn, :species),
      name: 'alba',
      parent: original_genus,
      verbatim_author: 'Smith',
      year_of_publication: 2000
    )

    species_rufa = Protonym.create!(
      rank_class: Ranks.lookup(:iczn, :species),
      name: 'rufa',
      parent: genus,
      verbatim_author: 'Smith',
      year_of_publication: 2000
    )

    Protonym.create!(
      rank_class: Ranks.lookup(:iczn, :subspecies),
      name: 'minor',
      parent: species_rufa,
      original_genus:,
      original_species: original_species_alba,
      verbatim_author: 'Smith',
      year_of_publication: 2000
    )

    tsv = Export::Coldp::Files::Name.generate(otu, [])
    rows = CSV.parse(tsv, col_sep: "\t", headers: true)
    reified_row = rows.find { |r| r['scientificName'] == 'Ous alba minor' }

    expect(reified_row).not_to be_nil
    expect(reified_row['rank']).to eq('subspecies')
    expect(reified_row['uninomial']).to be_nil.or eq('')
    expect(reified_row['genus']).to eq('Ous')
    expect(reified_row['specificEpithet']).to eq('alba')
    expect(reified_row['infraspecificEpithet']).to eq('minor')
  end

end
