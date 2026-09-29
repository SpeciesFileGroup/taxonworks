require 'rails_helper'

describe Export::Coldp::Files::SpeciesEstimate, type: :model, group: :col do
  let!(:species) { FactoryBot.create(:iczn_species) }
  let!(:otu) { Otu.create!(taxon_name: species) }
  let(:otus_scope) { Export::Coldp.otus(otu.id) }

  def rows
    tsv = described_class.generate(otus_scope, {})
    CSV.parse(tsv, col_sep: "\t", headers: true)
  end

  def add_estimate(uri:, value:, subject: otu)
    predicate = FactoryBot.create(:valid_controlled_vocabulary_term_predicate, uri:)
    InternalAttribute.create!(attribute_subject: subject, predicate:, value: value.to_s)
  end

  specify 'no estimates → header-only tsv' do
    expect(rows).to be_empty
  end

  specify 'species_living uri maps to "species living"' do
    add_estimate(uri: 'https://api.checklistbank.org/vocab/estimatetype#species_living', value: 42)
    expect(rows.first['type']).to eq('species living')
    expect(rows.first['estimate']).to eq('42')
    expect(rows.first['taxonID']).to eq(otu.id.to_s)
  end

  specify 'species_extinct uri maps to "species extinct"' do
    add_estimate(uri: 'https://api.checklistbank.org/vocab/estimatetype#species_extinct', value: 7)
    expect(rows.first['type']).to eq('species extinct')
    expect(rows.first['estimate']).to eq('7')
  end

  specify 'estimated_species uri maps to "estimated species"' do
    add_estimate(uri: 'https://api.checklistbank.org/vocab/estimatetype#estimated_species', value: 500)
    expect(rows.first['type']).to eq('estimated species')
    expect(rows.first['estimate']).to eq('500')
  end

  specify 'unrelated data attributes are ignored' do
    unrelated = FactoryBot.create(
      :valid_controlled_vocabulary_term_predicate,
      uri: 'https://example.org/not-an-estimate'
    )
    InternalAttribute.create!(attribute_subject: otu, predicate: unrelated, value: '99')

    expect(rows).to be_empty
  end

  specify 'data attributes on OTUs outside the scope are excluded' do
    outside_otu = Otu.create!(name: 'outside')
    add_estimate(uri: 'https://api.checklistbank.org/vocab/estimatetype#species_living', value: 999, subject: outside_otu)

    expect(rows).to be_empty
  end

  specify 'referenceID is populated from the citation source when the estimate is cited' do
    add_estimate(uri: 'https://api.checklistbank.org/vocab/estimatetype#species_living', value: 42)
    da = InternalAttribute.last
    source = FactoryBot.create(:valid_source_bibtex)
    Citation.create!(citation_object: da, source:)

    expect(rows.first['referenceID']).to eq(source.id.to_s)
  end

  specify 'multiple estimates on the same OTU produce one row each' do
    add_estimate(uri: 'https://api.checklistbank.org/vocab/estimatetype#species_living', value: 42)
    add_estimate(uri: 'https://api.checklistbank.org/vocab/estimatetype#species_extinct', value: 7)

    types = rows.map { |r| r['type'] }
    expect(types).to contain_exactly('species living', 'species extinct')
  end
end
