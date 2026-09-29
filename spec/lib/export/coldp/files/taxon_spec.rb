require 'rails_helper'

describe Export::Coldp::Files::Taxon, type: :model, group: :col do
  let!(:species) { FactoryBot.create(:iczn_species) }
  let!(:otu) { Otu.create!(taxon_name: species) }
  let(:otus_scope) { Export::Coldp.otus(otu.id) }

  def rows_for(coldp_profile: nil)
    tsv = described_class.generate(otu, otus_scope, {}, nil, true, coldp_profile:)
    CSV.parse(tsv, col_sep: "\t", headers: true)
  end

  def row_for(taxon_name_id, coldp_profile: nil)
    rows_for(coldp_profile:).detect { |r| r['nameID'].to_i == taxon_name_id }
  end

  describe 'fossil_extinct' do
    let!(:fossil_classification) do
      TaxonNameClassification::Iczn::Fossil.create!(taxon_name: species)
    end

    specify 'fossil_extinct = true marks fossils extinct' do
      row = row_for(species.id, coldp_profile: { 'fossil_extinct' => true })
      expect(row['extinct']).to eq('1')
    end

    specify 'fossil_extinct = false leaves fossils unmarked' do
      row = row_for(species.id, coldp_profile: { 'fossil_extinct' => false })
      expect(row['extinct']).to be_nil
    end

    specify 'no coldp_profile leaves fossils unmarked' do
      row = row_for(species.id)
      expect(row['extinct']).to be_nil
    end

    specify 'per-taxon extinct data attribute wins over fossil_extinct fallback' do
      predicate = FactoryBot.create(
        :valid_controlled_vocabulary_term_predicate,
        uri: Export::Coldp::Files::Taxon::IRI_MAP[:extinct]
      )
      InternalAttribute.create!(attribute_subject: otu, predicate:, value: '0')

      row = row_for(species.id, coldp_profile: { 'fossil_extinct' => true })
      expect(row['extinct']).to eq('0')
    end

    specify 'non-fossil taxa are not marked extinct even when fossil_extinct is set' do
      non_fossil_species = Protonym.create!(
        name: 'nonfossil',
        rank_class: Ranks.lookup(:iczn, :species),
        parent: species.parent
      )
      Otu.create!(taxon_name: non_fossil_species)

      # Move the scope up to a common ancestor so both species are included.
      genus_otu = Otu.create!(taxon_name: species.parent)
      genus_scope = Export::Coldp.otus(genus_otu.id)
      tsv = described_class.generate(genus_otu, genus_scope, {}, nil, true, coldp_profile: { 'fossil_extinct' => true })
      rows = CSV.parse(tsv, col_sep: "\t", headers: true)

      expect(rows.detect { |r| r['nameID'].to_i == non_fossil_species.id }['extinct']).to be_nil
      expect(rows.detect { |r| r['nameID'].to_i == species.id }['extinct']).to eq('1')
    end
  end

  describe 'default_lifezone' do
    specify 'default_lifezone fills environment when no per-taxon value is set' do
      row = row_for(species.id, coldp_profile: { 'default_lifezone' => 'marine' })
      expect(row['environment']).to eq('marine')
    end

    specify 'per-taxon lifezone wins over default_lifezone' do
      predicate = FactoryBot.create(
        :valid_controlled_vocabulary_term_predicate,
        uri: Export::Coldp::Files::Taxon::IRI_MAP[:lifezone]
      )
      InternalAttribute.create!(attribute_subject: otu, predicate:, value: 'freshwater')

      row = row_for(species.id, coldp_profile: { 'default_lifezone' => 'marine' })
      expect(row['environment']).to eq('freshwater')
    end

    specify 'blank default_lifezone does not populate environment' do
      row = row_for(species.id, coldp_profile: { 'default_lifezone' => '' })
      expect(row['environment']).to be_nil
    end
  end
end
