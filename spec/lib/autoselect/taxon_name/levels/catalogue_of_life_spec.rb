require 'rails_helper'

# Minimal Colrapi wire-format fixtures — see spec/lib/vendor/colrapi_spec.rb for the
# canonical shapes; duplicated in miniature here to keep this file self-contained.
def col_result_for_target(
  id:, scientific_name:, rank: 'genus', code: nil, authorship: nil
)
  {
    'id'     => id,
    'status' => 'accepted',
    'name'   => { 'scientificName' => scientific_name, 'rank' => rank, 'authorship' => authorship, 'code' => code },
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

      it "keeps CoL's full subgenus name on the record" do
        result = level.call(term: subgenus.name, project_id:, user_id:)
        expect(result.first.cached).to eq(subgenus.cached)
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

    context 'when the target is only a TaxonWorks name\'s original ' \
      'combination (a name TaxonWorks has since moved)' do
      let(:species) { subspecies.parent }
      let(:col_result) do
        col_result_for_target(
          id: 'TGT1', scientific_name: 'Typhlocyba vitis', rank: 'species'
        )
      end

      before do
        species.update_column(
          :cached_original_combination, 'Typhlocyba (Zygina) vitis'
        )
        allow(::Vendor::Colrapi).to receive(:search)
          .and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: 'Typhlocyba', rank: 'genus')
        ])
      end

      it 'does not match it' do
        result = level.call(term: 'Typhlocyba vitis', project_id:, user_id:)
        expect(result.first._col_extension[:target_taxonworks_id]).to be_nil
      end
    end

    context 'when the target is only a TaxonWorks Combination' do
      let(:species) { subspecies.parent }
      let!(:other_genus) do
        Protonym.create!(
          name: 'Otheronoma', rank_class: Ranks.lookup(:iczn, :genus),
          parent: tribe
        )
      end
      let!(:combination) { Combination.create!(genus: other_genus, species:) }
      let(:col_result) do
        col_result_for_target(
          id: 'TGT1', scientific_name: 'Otheronoma vitis', rank: 'species'
        )
      end

      before do
        allow(::Vendor::Colrapi).to receive(:search)
          .and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: 'Otheronoma', rank: 'genus')
        ])
      end

      it 'does not match it' do
        result = level.call(term: 'Otheronoma vitis', project_id:, user_id:)
        expect(result.first._col_extension[:target_taxonworks_id]).to be_nil
      end
    end

    context 'when a new ancestor of the target is only a TaxonWorks name\'s ' \
      'original combination' do
      let(:species) { subspecies.parent }
      let(:col_result) do
        col_result_for_target(
          id: 'TGT1', scientific_name: 'Typhlocyba vitis novus',
          rank: 'subspecies'
        )
      end

      before do
        species.update_column(
          :cached_original_combination, 'Typhlocyba (Zygina) vitis'
        )
        allow(::Vendor::Colrapi).to receive(:search)
          .and_return('result' => [col_result])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: tribe.cached, rank: 'tribe'),
          col_classification_entry(id: 'A2', name: 'Typhlocyba', rank: 'genus'),
          col_classification_entry(
            id: 'A3', name: 'Typhlocyba vitis', rank: 'species'
          )
        ])
      end

      it 'does not anchor on it' do
        result =
          level.call(term: 'Typhlocyba vitis novus', project_id:, user_id:)
        ext = result.first._col_extension
        expect(ext[:target_taxonworks_id]).to be_nil
        species_row = ext[:alignment].find { |r| r[:rank] == 'species' }
        expect(species_row[:match]).to eq('none')
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

    context 'when the target matches homonyms with different authorship' do
      let!(:smith) do
        Protonym.create!(
          name: 'Homonymus', rank_class: Ranks.lookup(:iczn, 'genus'),
          parent: family.root, verbatim_author: 'Smith',
          year_of_publication: 1900
        )
      end
      let!(:jones) do
        Protonym.create!(
          name: 'Homonymus', rank_class: Ranks.lookup(:iczn, 'genus'),
          parent: family.root, verbatim_author: 'Jones',
          year_of_publication: 1950
        )
      end

      def match_for(authorship)
        allow(::Vendor::Colrapi).to receive(:search).and_return(
          'result' => [
            col_result_for_target(
              id: 'TGT1', scientific_name: 'Homonymus', authorship:
            )
          ]
        )
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([])
        level.call(term: 'Homonymus', project_id:, user_id:)
          .first._col_extension
      end

      specify 'matches the one CoL\'s authorship agrees with' do
        expect(match_for('Jones, 1950')[:target_taxonworks_id])
          .to eq(jones.id)
      end

      specify 'ignores diacritics and case' do
        jones.update!(verbatim_author: 'Jönes')
        expect(match_for('JONES, 1950')[:target_taxonworks_id])
          .to eq(jones.id)
      end

      specify 'is still ambiguous when neither agrees' do
        expect(match_for('Jones, 1951')[:ambiguous_match])
          .to eq(rank: 'genus', col_name: 'Homonymus', count: 2)
      end

      specify 'is still ambiguous when both agree' do
        smith.update!(verbatim_author: 'Jones', year_of_publication: 1950)
        expect(match_for('Jones, 1950')[:ambiguous_match])
          .to eq(rank: 'genus', col_name: 'Homonymus', count: 2)
      end
    end

    context 'when the target matches homonyms whose authorship differs ' \
      'only in parentheses' do
      let!(:moved) do
        Protonym.create!(
          name: 'parens', rank_class: Ranks.lookup(:iczn, 'species'),
          parent: genus, verbatim_author: '(Walker)',
          year_of_publication: 1851
        )
      end
      let!(:unmoved) do
        Protonym.create!(
          name: 'parens', rank_class: Ranks.lookup(:iczn, 'species'),
          parent: genus, verbatim_author: 'Walker',
          year_of_publication: 1851
        )
      end

      before do
        allow(::Vendor::Colrapi).to receive(:search).and_return(
          'result' => [
            col_result_for_target(
              id: 'TGT1', scientific_name: "#{genus.cached} parens",
              rank: 'species', authorship: '(Walker, 1851)'
            )
          ]
        )
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([])
      end

      specify 'matches the one whose parentheses agree' do
        result = level.call(
          term: "#{genus.cached} parens", project_id:, user_id:
        )
        expect(result.first._col_extension[:target_taxonworks_id])
          .to eq(moved.id)
      end
    end

    context 'when the target matches one name, and CoL\'s authorship may be ' \
      'another taxon\'s' do
      # Trioza minuta (Mathur, 1975) vs Bactericera minuta (Crawford, 1910),
      # originally Trioza minuta - CoL lists both as Trioza minuta.
      let!(:mathur) do
        Protonym.create!(
          name: 'minuta', rank_class: Ranks.lookup(:iczn, 'species'),
          parent: genus, verbatim_author: 'Mathur',
          year_of_publication: 1975
        )
      end
      let!(:crawford) do
        other_genus = Protonym.create!(
          name: 'Bactericera', rank_class: Ranks.lookup(:iczn, 'genus'),
          parent: family.root
        )
        p = Protonym.create!(
          name: 'minuta', rank_class: Ranks.lookup(:iczn, 'species'),
          parent: other_genus, verbatim_author: 'Crawford',
          year_of_publication: 1910
        )
        p.update_column(
          :cached_original_combination, "#{genus.cached} minuta"
        )
        p
      end

      def match_for(authorship)
        allow(::Vendor::Colrapi).to receive(:search).and_return(
          'result' => [
            col_result_for_target(
              id: 'TGT1', scientific_name: "#{genus.cached} minuta",
              rank: 'species', authorship:
            )
          ]
        )
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([])
        level.call(term: "#{genus.cached} minuta", project_id:, user_id:)
          .first._col_extension
      end

      specify 'matches the current name, and reports CoL\'s other ' \
        'authorship' do
        ext = match_for('Crawford, 1910')
        expect(ext[:target_taxonworks_id]).to eq(mathur.id)
        expect(ext[:chain_consistent]).to be true
        expect(ext[:authorship_mismatch]).to eq(
          rank: 'species',
          col_name: "#{genus.cached} minuta",
          col_authorship: 'Crawford, 1910',
          taxonworks_name: mathur.cached,
          taxonworks_authorship: mathur.cached_author_year
        )
      end

      specify 'reports nothing when the authorship agrees, ignoring ' \
        'parentheses' do
        ext = match_for('(Mathur, 1975)')
        expect(ext[:target_taxonworks_id]).to eq(mathur.id)
        expect(ext).not_to have_key(:authorship_mismatch)
      end

      specify 'matches when CoL gives no authorship' do
        ext = match_for(nil)
        expect(ext[:target_taxonworks_id]).to eq(mathur.id)
        expect(ext).not_to have_key(:authorship_mismatch)
      end

      specify 'matches when CoL\'s authorship has no year' do
        ext = match_for('Crawford')
        expect(ext[:target_taxonworks_id]).to eq(mathur.id)
        expect(ext).not_to have_key(:authorship_mismatch)
      end
    end

    context 'when the anchor is an ancestor whose authorship differs from ' \
      'CoL\'s' do
      before do
        genus.update!(verbatim_author: 'Jones', year_of_publication: 1950)
        allow(::Vendor::Colrapi).to receive(:search).and_return(
          'result' => [
            col_result_for_target(
              id: 'TGT1', scientific_name: "#{genus.cached} novus",
              rank: 'species'
            )
          ]
        )
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([
          col_classification_entry(id: 'A1', name: genus.cached, rank: 'genus')
            .merge('authorship' => 'Smith, 1900')
        ])
      end

      specify 'anchors on it, and reports the ancestor\'s authorship' do
        ext = level.call(term: "#{genus.cached} novus", project_id:, user_id:)
          .first._col_extension
        expect(ext[:target_taxonworks_id]).to be_nil
        expect(ext[:chain_consistent]).to be true
        expect(ext[:alignment].last).to include(rank: 'genus', match: 'exact')
        expect(ext[:authorship_mismatch]).to include(
          rank: 'genus', col_authorship: 'Smith, 1900',
          taxonworks_authorship: 'Jones, 1950'
        )
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

    context 'when the target matches a TaxonWorks invalid name' do
      let!(:invalid) do
        Protonym.create!(
          name: 'Invalidonomus', rank_class: Ranks.lookup(:iczn, 'genus'),
          parent: family.root, project_id:, by: user_id
        ).tap { |t| t.update_column(:cached_is_valid, false) }
      end

      before do
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([])
      end

      def extension_for(status)
        col_result = col_result_for_target(
          id: 'TGT1', scientific_name: 'Invalidonomus'
        ).merge('status' => status)
        allow(::Vendor::Colrapi).to receive(:search)
          .and_return('result' => [col_result])
        level.call(term: 'Invalidonomus', project_id:, user_id:)
          .first._col_extension
      end

      specify 'doesn\'t match it when CoL accepts the name' do
        expect(extension_for('accepted')[:target_taxonworks_id]).to be_nil
      end

      specify 'matches the valid homonym, not ambiguously' do
        valid = Protonym.create!(
          name: 'Invalidonomus', rank_class: Ranks.lookup(:iczn, 'genus'),
          parent: family.root, project_id:, by: user_id
        )
        ext = extension_for('accepted')
        expect(ext[:ambiguous_match]).to be_nil
        expect(ext[:target_taxonworks_id]).to eq(valid.id)
      end

      specify 'matches it when CoL has it as a synonym too' do
        expect(extension_for('synonym')[:target_taxonworks_id])
          .to eq(invalid.id)
      end
    end

    context 'when the target\'s rank isn\'t one of its code\'s ranks' do
      before do
        allow(::Vendor::Colrapi).to receive(:search).and_return(
          'result' => [
            col_result_for_target(
              id: 'TGT1', scientific_name: 'Aus bus cus', rank: 'variety',
              code: 'zoological'
            )
          ]
        )
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([])
      end

      specify 'flags target_rank_unknown, even if another code has it' do
        result = level.call(term: 'Aus bus cus', project_id:, user_id:)
        expect(result.first._col_extension[:target_rank_unknown]).to be true
      end
    end

    context 'when a CoL usage has no scientificName' do
      let(:nameless) do
        col_result_for_target(id: 'TGT0', scientific_name: nil)
          .merge('label' => 'Brandnewonoma Smith, 1900')
      end
      let(:named) do
        col_result_for_target(id: 'TGT1', scientific_name: 'Brandnewonoma')
      end

      before do
        allow(::Vendor::Colrapi).to receive(:search)
          .and_return('result' => [nameless, named])
        allow(::Vendor::Colrapi).to receive(:ancestors).and_return([])
      end

      it 'skips it rather than falling back to the authored label' do
        result = level.call(term: 'Brandnewonoma', project_id:, user_id:)
        expect(result.map(&:cached)).to eq(['Brandnewonoma'])
      end
    end

    context 'without a project_id' do
      before do
        allow(::Vendor::Colrapi).to receive(:search).and_return(
          'result' => [
            col_result_for_target(id: 'TGT1', scientific_name: 'Brandnewonoma')
          ]
        )
      end

      it 'raises instead of matching against no project' do
        expect { level.call(term: 'Brandnewonoma', project_id: nil) }
          .to raise_error(ArgumentError, /project_id/)
      end
    end
  end
  describe '#record_info_html' do
    def result(target_taxonworks_id)
      OpenStruct.new(
        cached: 'Aus bus',
        _col_extension: { col_status: 'accepted', col_rank: 'species', target_taxonworks_id: }
      )
    end

    it 'marks a name already in TaxonWorks with the TW icon, then its CoL badges' do
      html = level.record_info_html(result(1))
      expect(html).to start_with(described_class::TW_ICON)
      expect(html).to include('accepted', 'species')
    end

    it 'marks a name that would be created with the CoL icon' do
      expect(level.record_info_html(result(nil)))
        .to start_with(described_class::COL_ICON)
    end
  end
end
