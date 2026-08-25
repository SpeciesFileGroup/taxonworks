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

  context 'candidates' do
    let!(:homonym) do
      Protonym.create!(name: 'eus', rank_class: Ranks.lookup(:iczn, :species), parent: genus).tap do |tn|
        tn.update_columns(cached: valid_species.cached)
      end
    end

    specify 'are not included by default' do
      expect(match(names: [valid_species.cached]).first).not_to have_key(:candidates)
    end

    specify 'are returned, ranked, when requested' do
      result = match(names: [valid_species.cached], candidates: 5).first
      expect(result[:candidates].map(&:id)).to contain_exactly(valid_species.id, homonym.id)
    end

    specify 'are capped at the requested count' do
      result = match(names: [valid_species.cached], candidates: 1).first
      expect(result[:candidates].size).to eq(1)
    end

    specify 'are empty when nothing matches' do
      expect(match(names: ['Nus nus'], candidates: 5).first[:candidates]).to eq([])
    end
  end

  context 'match_original_combination' do
    let!(:recombined) do
      Protonym.create!(name: 'fus', rank_class: Ranks.lookup(:iczn, :species), parent: genus).tap do |tn|
        tn.update_columns(cached_original_combination: 'Xus fus')
      end
    end

    specify 'the original combination is not matched by default' do
      expect(match(names: ['Xus fus']).first[:matched]).to eq(false)
    end

    specify 'the original combination is matched when enabled' do
      result = match(names: ['Xus fus'], match_original_combination: true).first
      expect(result[:taxon_name_id]).to eq(recombined.id)
    end
  end

  context 'use_author_year' do
    let!(:authored) do
      Protonym.create!(name: 'gus', rank_class: Ranks.lookup(:iczn, :species), parent: genus).tap do |tn|
        tn.update_columns(cached: 'Aus gus', cached_author_year: 'Smith, 1920')
      end
    end

    specify 'author/year is not consulted when a single candidate matches' do
      result = match(names: ['Aus gus Jones, 1899'], use_author_year: true).first
      expect(result[:taxon_name_id]).to eq(authored.id)
    end

    context 'when more than one candidate matches' do
      let!(:other_authored) do
        Protonym.create!(name: 'hus', rank_class: Ranks.lookup(:iczn, :species), parent: genus).tap do |tn|
          tn.update_columns(cached: 'Aus gus', cached_author_year: 'Jones, 1899')
        end
      end

      specify 'author/year differentiates the match' do
        result = match(names: ['Aus gus Jones, 1899'], use_author_year: true).first
        expect(result[:taxon_name_id]).to eq(other_authored.id)
      end

      specify 'all candidates are retained when none match the author/year' do
        result = match(names: ['Aus gus Brown, 1800'], use_author_year: true, candidates: 5).first
        expect(result[:candidates].map(&:id)).to contain_exactly(authored.id, other_authored.id)
      end
    end
  end

  context 'try_without_subgenus' do
    # Matches through the live classification (taxon_name_hierarchies + current name/rank),
    # not through any cached column — see lib/match/otu/taxon_name.rb.
    let(:subgenus) { Protonym.create!(name: 'Bus', rank_class: Ranks.lookup(:iczn, :subgenus), parent: genus) }

    let!(:species_under_subgenus) do
      Protonym.create!(name: 'maculatus', rank_class: Ranks.lookup(:iczn, :species), parent: subgenus)
    end

    specify 'is not matched when try_without_subgenus is disabled' do
      result = match(names: ['Aus maculata'], try_without_subgenus: false).first
      expect(result[:matched]).to eq(false)
    end

    context '2 words (Genus species), subgenus omitted from the search string' do
      specify 'a feminine-ending search matches the stored masculine species' do
        result = match(names: ['Aus maculata'], try_without_subgenus: true).first
        expect(result[:taxon_name_id]).to eq(species_under_subgenus.id)
      end
    end

    context '3 words (Genus Subgenus species), subgenus present but ignored' do
      specify 'the middle word is never inspected, even when it matches nothing real' do
        result = match(names: ['Aus Nonsense maculata'], try_without_subgenus: true).first
        expect(result[:taxon_name_id]).to eq(species_under_subgenus.id)
      end

      specify 'the real subgenus name works too' do
        result = match(names: ['Aus Bus maculata'], try_without_subgenus: true).first
        expect(result[:taxon_name_id]).to eq(species_under_subgenus.id)
      end
    end

    context '3 words (Genus species subspecies), no subgenus at all' do
      let!(:species_no_subgenus) do
        Protonym.create!(name: 'dus', rank_class: Ranks.lookup(:iczn, :species), parent: genus)
      end

      let!(:subspecies_no_subgenus) do
        Protonym.create!(name: 'radiatus', rank_class: Ranks.lookup(:iczn, :subspecies), parent: species_no_subgenus)
      end

      specify 'falls back to subspecies-terminal when species-terminal finds nothing' do
        result = match(names: ['Aus dus radiata'], try_without_subgenus: true).first
        expect(result[:taxon_name_id]).to eq(subspecies_no_subgenus.id)
      end
    end

    context '4 words (Genus Subgenus species subspecies)' do
      let!(:subspecies_under_subgenus) do
        Protonym.create!(name: 'nigratus', rank_class: Ranks.lookup(:iczn, :subspecies), parent: species_under_subgenus)
      end

      specify 'the species (second-to-last word) must match exactly, subspecies epithet gender-matches' do
        result = match(names: ['Aus Bus maculatus nigrata'], try_without_subgenus: true).first
        expect(result[:taxon_name_id]).to eq(subspecies_under_subgenus.id)
      end

      specify 'a species epithet that does not match exactly finds nothing' do
        result = match(names: ['Aus Bus maculata nigrata'], try_without_subgenus: true).first
        expect(result[:matched]).to eq(false)
      end
    end

    context 'word counts other than 2, 3, or 4' do
      specify 'gives up rather than guessing' do
        result = match(names: ['Aus Bus maculatus nigratus extra'], try_without_subgenus: true).first
        expect(result[:matched]).to eq(false)
      end
    end
  end

  context 'fuzzy matching' do
    specify 'matches within the levenshtein distance' do
      result = match(names: ['Aus bux'], levenshtein_distance: 2).first
      expect(result[:taxon_name_id]).to eq(valid_species.id)
    end

    specify 'does not match beyond the levenshtein distance' do
      expect(match(names: ['Aus bux'], levenshtein_distance: 0).first[:matched]).to eq(false)
    end

    specify 'matches with the trigram prefilter enabled' do
      result = match(names: ['Aus bux'], levenshtein_distance: 2, trigram_prefilter: true).first
      expect(result[:taxon_name_id]).to eq(valid_species.id)
    end

    context 'across cached and cached_original_combination' do
      let!(:recombined) do
        Protonym.create!(name: 'jus', rank_class: Ranks.lookup(:iczn, :species), parent: genus).tap do |tn|
          tn.update_columns(cached_original_combination: 'Yus jus')
        end
      end

      specify 'matches the nearest of the two columns' do
        result = match(
          names: ['Yus jux'],
          levenshtein_distance: 2,
          match_original_combination: true,
          trigram_prefilter: true
        ).first

        expect(result[:taxon_name_id]).to eq(recombined.id)
      end
    end
  end

  context 'taxon_name_query' do
    let(:other_genus) { Protonym.create!(name: 'Xus', rank_class: Ranks.lookup(:iczn, :genus), parent: root) }

    let!(:out_of_scope) do
      Protonym.create!(name: 'ius', rank_class: Ranks.lookup(:iczn, :species), parent: other_genus).tap do |tn|
        tn.update_columns(cached: 'Zus zus')
      end
    end

    specify 'restricts matches to the query result' do
      result = match(
        names: ['Zus zus'],
        taxon_name_query: { taxon_name_id: [genus.id], descendants: true }
      ).first

      expect(result[:matched]).to eq(false)
    end

    specify 'matches within the query result' do
      result = match(
        names: ['Zus zus'],
        taxon_name_query: { taxon_name_id: [other_genus.id], descendants: true }
      ).first

      expect(result[:taxon_name_id]).to eq(out_of_scope.id)
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
