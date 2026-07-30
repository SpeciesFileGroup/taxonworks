require 'rails_helper'

describe Match::Otu::TaxonName, type: :model do
  let(:root)  { FactoryBot.create(:root_taxon_name) }
  let(:genus) { Protonym.create!(name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }

  let(:valid_species) do
    Protonym.create!(name: 'bus', rank_class: Ranks.lookup(:iczn, :species), parent: genus)
  end

  let(:synonym_species) do
    Protonym.create!(name: 'cus', rank_class: Ranks.lookup(:iczn, :species), parent: genus)
  end

  let!(:synonym_relationship) do
    TaxonNameRelationship::Iczn::Invalidating::Synonym.create!(
      subject_taxon_name: synonym_species,
      object_taxon_name: valid_species
    )
  end

  let(:project_id) { synonym_species.project_id }

  def match(names:, **opts)
    Match::Otu::TaxonName.new(names:, project_id:, **opts).call
  end

  context 'resolve_synonyms' do
    context 'when the valid name has an OTU and the synonym does not' do
      let!(:valid_otu) { Otu.create!(taxon_name: valid_species) }

      specify 'returns the valid name and its OTU' do
        result = match(names: [synonym_species.cached], resolve_synonyms: true).first
        expect(result[:taxon_name_id]).to eq(valid_species.id)
        expect(result[:otus].map(&:id)).to contain_exactly(valid_otu.id)
      end
    end

    context 'when the synonym has an OTU but the valid name does not' do
      let!(:synonym_otu) { Otu.create!(taxon_name: synonym_species) }

      specify 'returns the valid name with no OTUs, not the synonym' do
        result = match(names: [synonym_species.cached], resolve_synonyms: true).first
        expect(result[:taxon_name_id]).to eq(valid_species.id)
        expect(result[:otus]).to be_empty
      end
    end
  end

  context 'ambiguous' do
    context 'when multiple candidates share a cached name but resolve to the same valid taxon (e.g. a Combination alongside its own Protonym)' do
      let!(:combination_like) do
        Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: genus).tap do |tn|
          tn.update_columns(cached: valid_species.cached, cached_valid_taxon_name_id: valid_species.id)
        end
      end

      specify 'is not flagged ambiguous' do
        result = match(names: [valid_species.cached]).first
        expect(result[:ambiguous]).to eq(false)
      end
    end

    context 'when multiple candidates share a cached name but resolve to different valid taxa (true homonyms)' do
      let!(:homonym) do
        Protonym.create!(name: 'eus', rank_class: Ranks.lookup(:iczn, :species), parent: genus).tap do |tn|
          tn.update_columns(cached: valid_species.cached)
        end
      end

      specify 'is flagged ambiguous' do
        result = match(names: [valid_species.cached]).first
        expect(result[:ambiguous]).to eq(true)
      end
    end
  end
end
