require 'rails_helper'

# Minimal Colrapi wire-format fixtures — see spec/lib/vendor/colrapi_spec.rb for the
# canonical shapes; duplicated in miniature here to keep this file self-contained.
def col_result_for_target(id:, scientific_name:, rank: 'genus', code: nil)
  {
    'id'     => id,
    'status' => 'accepted',
    'name'   => { 'scientificName' => scientific_name, 'rank' => rank, 'authorship' => nil, 'code' => code },
    'label'     => scientific_name,
    'labelHtml' => scientific_name
  }
end

def col_classification_entry(id:, name:, rank:)
  { 'id' => id, 'name' => name, 'rank' => rank, 'label' => name, 'labelHtml' => name }
end

RSpec.describe Autoselect::TaxonName::Levels::CatalogueOfLife, type: :model do
  subject(:level) { described_class.new }

  # A real, consistent local lineage — order -> family -> subfamily -> tribe -> ... -> genus.
  let(:subspecies) { FactoryBot.create(:iczn_subspecies) }
  let(:genus) { subspecies.ancestor_at_rank('genus') }
  let(:tribe) { subspecies.ancestor_at_rank('tribe') }
  let(:family) { subspecies.ancestor_at_rank('family') }

  def match_rows(result)
    result.first._col_extension[:alignment].map { |r| [r[:rank], r[:match]] }
  end

  describe '#call — matching against TaxonWorks' do
    context 'when nothing in the chain matches a local name (all-new)' do
      let(:col_result) { col_result_for_target(id: 'TGT1', scientific_name: 'Brandnewonoma') }

      before do
        allow(::Vendor::Colrapi).to receive(:search).and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: 'Brandnewidae', rank: 'family')
        ])
      end

      it 'has no target match and every row is none (to be created)' do
        result = level.call(term: 'Brandnewonoma', project_id:, user_id:)
        expect(result.first._col_extension[:target_taxonworks_id]).to be_nil
        expect(match_rows(result)).to eq([['family', 'none']])
      end

      it 'is chain_consistent (nothing to conflict)' do
        result = level.call(term: 'Brandnewonoma', project_id:, user_id:)
        expect(result.first._col_extension[:chain_consistent]).to be true
      end
    end

    context 'when a real local lineage anchors the match at an ancestor rank (tribe), target is new' do
      let(:col_result) { col_result_for_target(id: 'TGT1', scientific_name: 'Brandnewonoma') }

      before do
        allow(::Vendor::Colrapi).to receive(:search).and_return('result' => [col_result])
        # Vendor::Colrapi.ancestors (the real ChecklistBank classification subresource)
        # returns kingdom-first — confirmed directly against the live API.
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: family.cached, rank: 'family'),
          col_classification_entry(id: 'A2', name: tribe.cached, rank: 'tribe')
        ])
      end

      it 'anchors at tribe and shows the real TW-only ranks above it as extra (alignment excludes the target row, reported separately)' do
        result = level.call(term: 'Brandnewonoma', project_id:, user_id:)
        # kingdom/phylum/class/order (real ancestors TW has that CoL's chain doesn't mention
        # here) are 'extra'; subfamily (between family and tribe in the real lineage) too.
        expect(match_rows(result)).to eq([
          ['kingdom', 'extra'],
          ['phylum', 'extra'],
          ['class', 'extra'],
          ['order', 'extra'],
          ['family', 'exact'],
          ['subfamily', 'extra'],
          ['tribe', 'exact']
        ])
        expect(result.first._col_extension[:target_taxonworks_id]).to be_nil
      end

      it 'is chain_consistent' do
        result = level.call(term: 'Brandnewonoma', project_id:, user_id:)
        expect(result.first._col_extension[:chain_consistent]).to be true
      end
    end

    context 'when a same-named ancestor exists elsewhere in the project, unrelated to the actual anchor' do
      # A genuinely unrelated name — NOT built via the :iczn_genus factory, since its
      # nested associations hardcode the same family name ('Cicadellidae') as `family`
      # above, which would make the two families indistinguishable by cached-name match.
      let(:other_genus) do
        Protonym.create!(
          name: 'Unrelatedonoma',
          rank_class: Ranks.lookup(:iczn, 'genus'),
          parent: family.root,
          project_id:,
          by: user_id
        )
      end
      let(:col_result) { col_result_for_target(id: 'TGT1', scientific_name: other_genus.cached) }

      before do
        allow(::Vendor::Colrapi).to receive(:search).and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: family.cached, rank: 'family'),
          col_classification_entry(id: 'A2', name: tribe.cached, rank: 'tribe')
        ])
      end

      # Regression: the old row-by-row independent matching (see Vendor::Colrapi.build_extension's
      # history) would have paired `family`/`tribe` here to the *unrelated* subspecies lineage's
      # real records just because the names happened to match — the anchor-based approach never
      # looks at them at all, since it stops at the first (most proximal) match: the target itself.
      it 'anchors at the target and does not pull in the coincidentally-same-named family/tribe' do
        result = level.call(term: other_genus.cached, project_id:, user_id:)
        expect(result.first._col_extension[:target_taxonworks_id]).to eq(other_genus.id)
        expect(match_rows(result)).to eq([
          ['family', 'none'],
          ['tribe', 'none']
        ])
      end

      it 'is chain_consistent — nothing actually disagrees, family/tribe are simply not yet recorded for this lineage' do
        result = level.call(term: other_genus.cached, project_id:, user_id:)
        expect(result.first._col_extension[:chain_consistent]).to be true
      end
    end

    context "when TaxonWorks' real ancestor at a rank has a genuinely different name than CoL (a true conflict)" do
      let(:col_result) { col_result_for_target(id: 'TGT1', scientific_name: genus.cached) }

      before do
        allow(::Vendor::Colrapi).to receive(:search).and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: 'ColSaysThisFamily', rank: 'family'),
          col_classification_entry(id: 'A2', name: tribe.cached, rank: 'tribe')
        ])
      end

      it 'flags the family row as conflict, carrying both names' do
        result = level.call(term: genus.cached, project_id:, user_id:)
        row = result.first._col_extension[:alignment].find { |r| r[:rank] == 'family' }
        expect(row[:match]).to eq('conflict')
        expect(row[:col_name]).to eq('ColSaysThisFamily')
        expect(row[:taxonworks_name]).to eq(family.cached)
      end

      it 'is not chain_consistent' do
        result = level.call(term: genus.cached, project_id:, user_id:)
        expect(result.first._col_extension[:chain_consistent]).to be false
      end

      it 'still matches the target and the tribe row exactly' do
        result = level.call(term: genus.cached, project_id:, user_id:)
        expect(result.first._col_extension[:target_taxonworks_id]).to eq(genus.id)
        tribe_row = result.first._col_extension[:alignment].find { |r| r[:rank] == 'tribe' }
        expect(tribe_row[:match]).to eq('exact')
      end
    end

    context 'when the target and its whole real lineage agree with CoL' do
      let(:col_result) { col_result_for_target(id: 'TGT1', scientific_name: genus.cached) }

      before do
        allow(::Vendor::Colrapi).to receive(:search).and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: family.cached, rank: 'family'),
          col_classification_entry(id: 'A2', name: tribe.cached, rank: 'tribe')
        ])
      end

      it 'matches the target exactly and is chain_consistent' do
        result = level.call(term: genus.cached, project_id:, user_id:)
        expect(result.first._col_extension[:target_taxonworks_id]).to eq(genus.id)
        expect(result.first._col_extension[:chain_consistent]).to be true
      end

      it 'shows the real TW-only ancestors (kingdom, phylum, class, order, subfamily, subtribe) as extra' do
        result = level.call(term: genus.cached, project_id:, user_id:)
        expect(match_rows(result)).to eq([
          ['kingdom', 'extra'],
          ['phylum', 'extra'],
          ['class', 'extra'],
          ['order', 'extra'],
          ['family', 'exact'],
          ['subfamily', 'extra'],
          ['tribe', 'exact'],
          ['subtribe', 'extra']
        ])
      end
    end

    # CoL gives a subgenus as its bare epithet ('Erythroneura'), while TW's
    # subgenus cached is the combination 'Erythroneura (Erythroneura)'.
    context 'when a real local subgenus is in the CoL chain above a new target' do
      let(:subgenus) { subspecies.ancestor_at_rank('subgenus') }
      let(:col_result) do
        col_result_for_target(
          id: 'TGT1', scientific_name: 'Erythroneura novus', rank: 'species'
        )
      end

      before do
        allow(::Vendor::Colrapi).to receive(:search)
          .and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: genus.cached, rank: 'genus'),
          col_classification_entry(
            id: 'A2', name: subgenus.cached, rank: 'subgenus'
          )
        ])
      end

      it 'anchors at the subgenus and matches it exactly' do
        result = level.call(term: 'Erythroneura novus', project_id:, user_id:)
        subgenus_row = result.first._col_extension[:alignment]
          .find { |r| r[:rank] == 'subgenus' }
        expect(subgenus_row[:match]).to eq('exact')
        expect(subgenus_row[:taxonworks_id]).to eq(subgenus.id)
        expect(result.first._col_extension[:chain_consistent]).to be true
      end
    end

    context 'when the target is a real local subgenus' do
      let(:subgenus) { subspecies.ancestor_at_rank('subgenus') }
      let(:col_result) do
        col_result_for_target(
          id: 'TGT1', scientific_name: subgenus.cached, rank: 'subgenus'
        )
      end

      before do
        allow(::Vendor::Colrapi).to receive(:search)
          .and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: genus.cached, rank: 'genus')
        ])
      end

      it 'matches the target subgenus instead of offering to create it' do
        result = level.call(term: subgenus.name, project_id:, user_id:)
        ext = result.first._col_extension
        expect(ext[:target_taxonworks_id]).to eq(subgenus.id)
        expect(ext[:chain_consistent]).to be true
      end
    end

    # CoL includes or omits the subgenus in species-group names depending on
    # the source (seen: mosquitoes include it, bees omit it, Carabus species
    # include it but its subspecies omit it).
    context 'when CoL omits the subgenus TaxonWorks places a species in' do
      let(:species) { subspecies.parent }
      let(:col_result) do
        col_result_for_target(
          id: 'TGT1', scientific_name: 'Erythroneura vitis', rank: 'species'
        )
      end

      before do
        allow(::Vendor::Colrapi).to receive(:search)
          .and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: genus.cached, rank: 'genus')
        ])
      end

      it 'matches the existing species' do
        result = level.call(term: 'Erythroneura vitis', project_id:, user_id:)
        ext = result.first._col_extension
        expect(ext[:target_taxonworks_id]).to eq(species.id)
        expect(ext[:chain_consistent]).to be true
      end
    end

    context 'when CoL includes a subgenus TaxonWorks does not place the ' \
      'species in' do
      let!(:novus) do
        Protonym.create!(
          name: 'novus', rank_class: Ranks.lookup(:iczn, :species),
          parent: genus, project_id:, by: user_id
        )
      end
      let(:col_result) do
        col_result_for_target(
          id: 'TGT1', scientific_name: 'Erythroneura (Erythroneura) novus',
          rank: 'species'
        )
      end

      before do
        allow(::Vendor::Colrapi).to receive(:search)
          .and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: genus.cached, rank: 'genus'),
          col_classification_entry(
            id: 'A2', name: 'Erythroneura (Erythroneura)', rank: 'subgenus'
          )
        ])
      end

      it 'matches the existing species' do
        result = level.call(
          term: 'Erythroneura (Erythroneura) novus', project_id:, user_id:
        )
        expect(result.first._col_extension[:target_taxonworks_id])
          .to eq(novus.id)
      end
    end

    context 'when CoL omits the subgenus from a subspecies but not from its ' \
      'species' do
      let(:species) { subspecies.parent }
      let(:col_result) do
        col_result_for_target(
          id: 'TGT1', scientific_name: 'Erythroneura vitis vitata',
          rank: 'subspecies'
        )
      end

      before do
        allow(::Vendor::Colrapi).to receive(:search)
          .and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: genus.cached, rank: 'genus'),
          col_classification_entry(
            id: 'A2', name: 'Erythroneura (Erythroneura)', rank: 'subgenus'
          ),
          col_classification_entry(
            id: 'A3', name: 'Erythroneura (Erythroneura) vitis', rank: 'species'
          )
        ])
      end

      it 'matches the existing subspecies' do
        result = level.call(
          term: 'Erythroneura vitis vitata', project_id:, user_id:
        )
        ext = result.first._col_extension
        expect(ext[:target_taxonworks_id]).to eq(subspecies.id)
        expect(ext[:chain_consistent]).to be true
      end
    end

    context 'when the target itself matches multiple homonym records (same name, same rank)' do
      let!(:homonym_a) do
        Protonym.create!(name: 'Homonymus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: family.root, project_id:, by: user_id)
      end
      let!(:homonym_b) do
        Protonym.create!(name: 'Homonymus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: family.root, project_id:, by: user_id)
      end
      let(:col_result) { col_result_for_target(id: 'TGT1', scientific_name: 'Homonymus') }

      before do
        allow(::Vendor::Colrapi).to receive(:search).and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([])
      end

      it 'is not chain_consistent and reports which rank/name was ambiguous, and how many candidates' do
        result = level.call(term: 'Homonymus', project_id:, user_id:)
        ext = result.first._col_extension
        expect(ext[:chain_consistent]).to be false
        expect(ext[:ambiguous_match]).to eq(rank: 'genus', col_name: 'Homonymus', count: 2)
      end

      it 'does not guess a target_taxonworks_id' do
        result = level.call(term: 'Homonymus', project_id:, user_id:)
        expect(result.first._col_extension[:target_taxonworks_id]).to be_nil
      end
    end

    context 'when an ancestor rank (not the target) matches multiple homonym records' do
      let!(:homonym_a) do
        Protonym.create!(name: 'Homonymidae', rank_class: Ranks.lookup(:iczn, 'family'), parent: family.root, project_id:, by: user_id)
      end
      let!(:homonym_b) do
        Protonym.create!(name: 'Homonymidae', rank_class: Ranks.lookup(:iczn, 'family'), parent: family.root, project_id:, by: user_id)
      end
      let(:col_result) { col_result_for_target(id: 'TGT1', scientific_name: 'Brandnewonoma') }

      before do
        allow(::Vendor::Colrapi).to receive(:search).and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: 'Homonymidae', rank: 'family')
        ])
      end

      it 'is not chain_consistent and reports the ambiguous ancestor rank' do
        result = level.call(term: 'Brandnewonoma', project_id:, user_id:)
        ext = result.first._col_extension
        expect(ext[:chain_consistent]).to be false
        expect(ext[:ambiguous_match]).to eq(rank: 'family', col_name: 'Homonymidae', count: 2)
      end
    end

    context 'when an ancestor rank has same-name, same-rank candidates under two different nomenclatural codes, and CoL specifies the code' do
      # Family-rank names are suffix-constrained per code (-idae vs -aceae) and can never
      # collide as strings, so this uses genus rank — real cross-code homonyms (e.g. a
      # zoological vs a botanical genus sharing a name) are unconstrained bare words.
      let!(:iczn_homonym) do
        Protonym.create!(name: 'Homonymus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: family.root, project_id:, by: user_id)
      end
      let!(:icn_homonym) do
        Protonym.create!(name: 'Homonymus', rank_class: Ranks.lookup(:icn, 'genus'), parent: family.root, project_id:, by: user_id)
      end
      let(:col_result) { col_result_for_target(id: 'TGT1', scientific_name: 'newella', rank: 'species', code: 'zoological') }

      before do
        allow(::Vendor::Colrapi).to receive(:search).and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: 'Homonymus', rank: 'genus')
        ])
      end

      it 'is not ambiguous — the nomenclatural code disambiguates the two same-name, same-rank candidates' do
        result = level.call(term: 'newella', project_id:, user_id:)
        ext = result.first._col_extension
        expect(ext[:ambiguous_match]).to be_nil
        expect(ext[:chain_consistent]).to be true
      end

      it 'anchors on the candidate matching the CoL-specified code, not the other-code homonym' do
        result = level.call(term: 'newella', project_id:, user_id:)
        genus_row = result.first._col_extension[:alignment].find { |r| r[:rank] == 'genus' }
        expect(genus_row[:taxonworks_id]).to eq(iczn_homonym.id)
        expect(genus_row[:match]).to eq('exact')
      end
    end

    context 'when CoL specifies no code and same-name, same-rank candidates exist under two different codes' do
      let!(:iczn_homonym) do
        Protonym.create!(name: 'Homonymus', rank_class: Ranks.lookup(:iczn, 'genus'), parent: family.root, project_id:, by: user_id)
      end
      let!(:icn_homonym) do
        Protonym.create!(name: 'Homonymus', rank_class: Ranks.lookup(:icn, 'genus'), parent: family.root, project_id:, by: user_id)
      end
      let(:col_result) { col_result_for_target(id: 'TGT1', scientific_name: 'newella', rank: 'species') }

      before do
        allow(::Vendor::Colrapi).to receive(:search).and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: 'Homonymus', rank: 'genus')
        ])
      end

      it 'falls back to the old ambiguous behavior — there is no code to disambiguate with' do
        result = level.call(term: 'newella', project_id:, user_id:)
        ext = result.first._col_extension
        expect(ext[:chain_consistent]).to be false
        expect(ext[:ambiguous_match]).to eq(rank: 'genus', col_name: 'Homonymus', count: 2)
      end
    end

    context 'when a same-named candidate exists only at a different rank than CoL expects' do
      let!(:wrong_rank_namesake) do
        Protonym.create!(name: 'Brandnewonomidae', rank_class: Ranks.lookup(:iczn, 'family'), parent: family.root, project_id:, by: user_id)
      end
      let(:col_result) { col_result_for_target(id: 'TGT1', scientific_name: 'Brandnewonomidae', rank: 'genus') }

      before do
        allow(::Vendor::Colrapi).to receive(:search).and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([])
      end

      it 'does not treat the differently-ranked namesake as a match' do
        result = level.call(term: 'Brandnewonomidae', project_id:, user_id:)
        ext = result.first._col_extension
        expect(ext[:target_taxonworks_id]).to be_nil
        expect(ext[:chain_consistent]).to be true
        expect(ext[:ambiguous_match]).to be_nil
      end
    end
  end
end
