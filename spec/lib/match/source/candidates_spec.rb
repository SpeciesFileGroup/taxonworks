require 'rails_helper'

describe Match::Source::Candidates, type: :model do
  let(:project_id) { Current.project_id }

  let!(:source) do
    s = Source::Bibtex.create!(
      bibtex_type: 'article',
      author: 'Müller, J. and van der Merwe, A. and Smith, B.',
      year: 1990,
      title: 'Fleas of the <i>Peromyscus</i> of Indiana',
      journal: 'Journal of Parasitology',
      volume: '96',
      pages: '285-298',
      doi: 'https://doi.org/10.1645/GE-2251.1'
    )
    ProjectSource.create!(source: s, project_id:)
    s
  end

  let!(:other_source) do
    Source::Bibtex.create!(
      bibtex_type: 'article',
      author: 'Müller, J.',
      year: 1991,
      title: 'Something else entirely',
      journal: 'Zootaxa'
    )
  end

  def candidates(rows, **opts)
    Match::Source::Candidates.new(rows:, project_id:, **opts).call
  end

  def candidate_for(result, s)
    result[:candidates].detect { |c| c[:source].id == s.id }
  end

  specify 'returns each row as parsed' do
    r = candidates([{ authors: 'Müller, J.', year: '1990' }]).first
    expect(r[:input].surnames).to eq(['Müller'])
  end

  specify 'returns one result per row, in order' do
    r = candidates([{ authors: 'Müller', year: '1990' }, { verbatim: '' }])
    expect(r.map { |x| x[:index] }).to eq([0, 1])
    expect(r.last[:candidates]).to eq([])
  end

  context 'empty rows' do
    specify 'when every row is empty, each is returned without candidates' do
      r = candidates([{ verbatim: '' }, { authors: ' ', year: '' }])
      expect(r.map { |x| x[:index] }).to eq([0, 1])
      expect(r.map { |x| x[:candidates] }).to eq([[], []])
    end

    specify 'a row empty once parsed gets no candidates' do
      r = candidates([{ year: 'n.d.' }, { verbatim: '<br>' }])
      expect(r.map { |x| x[:candidates] }).to eq([[], []])
    end

    specify 'blank fields are ignored beside given ones' do
      r = candidates(
        [{ authors: 'Müller, J.', year: '1990', title: '', doi: ' ' }]
      ).first
      expect(r[:candidates].first[:source].id).to eq(source.id)
      expect(r[:candidates].first[:title_similarity]).to be_nil
      expect(r[:candidates].first[:doi_match]).to be_nil
    end

    specify 'an empty row between others keeps every row aligned' do
      r = candidates([
        { authors: 'Müller, J.', year: '1991' },
        { verbatim: '' },
        { authors: 'Müller, J.', year: '1990' }
      ])
      expect(r[1][:candidates]).to eq([])
      expect(r[0][:candidates].first[:source].id).to eq(other_source.id)
      expect(r[2][:candidates].first[:source].id).to eq(source.id)
    end

    specify 'with no rows' do
      expect(candidates([])).to eq([])
    end
  end

  context 'author and year' do
    let(:result) { candidates([{ authors: 'Müller, J.', year: '1990' }]).first }

    specify 'finds the Source' do
      expect(candidate_for(result, source)).to be_truthy
    end

    specify 'reports the year difference' do
      expect(candidate_for(result, source)[:year_difference]).to eq(0)
      expect(candidate_for(result, other_source)[:year_difference]).to eq(1)
    end

    specify 'reports an exact first author' do
      c = candidate_for(result, source)
      expect(c[:first_author_exact]).to be true
      expect(c[:first_author_distance]).to eq(0)
    end

    specify 'orders the best candidate first' do
      expect(result[:candidates].first[:source].id).to eq(source.id)
    end

    specify 'does not find Sources outside the year window' do
      r = candidates([{ authors: 'Müller', year: '1980' }], year_window: 2)
      expect(r.first[:candidates]).to eq([])
    end
  end

  context 'author comparison' do
    specify 'without diacritics' do
      c = candidate_for(
        candidates([{ authors: 'Muller', year: '1990' }]).first, source
      )
      expect(c[:first_author_exact]).to be false
      expect(c[:first_author_distance]).to eq(0)
    end

    specify 'misspelled' do
      c = candidate_for(
        candidates([{ authors: 'Mueller', year: '1990' }]).first, source
      )
      expect(c[:first_author_distance]).to eq(1)
    end

    specify 'all authors, particles ignored' do
      c = candidate_for(
        candidates([{
          authors: 'Muller, J., A. van der Merwe & B. Smith', year: '1990'
        }]).first,
        source
      )
      expect(c[:author_distances]).to eq([0, 0, 0])
      expect(c[:source_author_count]).to eq(3)
    end

    specify 'an author not in the Source' do
      c = candidate_for(
        candidates([{ authors: 'Müller & Jones', year: '1990' }]).first,
        source
      )
      expect(c[:author_distances].first).to eq(0)
      expect(c[:author_distances].last).to be > 2
    end
  end

  specify 'finds a Source whose first surname is also a particle' do
    du = Source::Bibtex.create!(
      bibtex_type: 'article', author: 'Du, X. and Ding, Y.', year: 1991,
      title: 'Notes'
    )
    r = candidates([{ authors: 'Du & Ding', year: '1991' }]).first
    expect(candidate_for(r, du)).to be_truthy
  end

  context 'year suffix' do
    def suffix_match(row_year)
      source.update_column(:year_suffix, 'a')
      r = candidates([{ authors: 'Müller', year: row_year }]).first
      candidate_for(r, source)[:year_suffix_match]
    end

    specify 'agrees whatever the case' do
      expect(suffix_match('1990a')).to be true
      expect(suffix_match('1990A')).to be true
    end

    specify 'disagrees when different' do
      expect(suffix_match('1990b')).to be false
    end
  end

  context 'compound surnames' do
    let!(:garcia_lopez) do
      Source::Bibtex.create!(
        bibtex_type: 'article', author: 'García López, J.', year: 2001,
        title: 'Cicadellidae of Spain'
      )
    end

    let!(:ravizza) do
      Source::Bibtex.create!(
        bibtex_type: 'article', author: 'Ravizza, C.', year: 2002,
        title: 'Plecoptera of Italy'
      )
    end

    specify 'a row citing only the first surname finds the Source' do
      r = candidates([{ authors: 'García, J.', year: '2001' }]).first
      expect(candidate_for(r, garcia_lopez)[:first_author_distance]).to eq(0)
    end

    specify 'a row citing only the last surname finds the Source' do
      r = candidates([{ authors: 'López, J.', year: '2001' }]).first
      expect(candidate_for(r, garcia_lopez)[:first_author_distance]).to eq(0)
    end

    specify 'a row with the compound finds a Source with its first surname' do
      r = candidates(
        [{ authors: 'Ravizza Dematteis, C.', year: '2002' }]
      ).first
      expect(candidate_for(r, ravizza)[:first_author_distance]).to eq(0)
    end

    specify 'a particle is not a surname word' do
      r = candidates([{ authors: 'van, A.', year: '1990' }]).first
      expect(candidate_for(r, source)).to be_nil
    end
  end

  context 'first author initials' do
    let!(:smit_b) do
      Source::Bibtex.create!(bibtex_type: 'article', author: 'Smit, B.', year: 1964)
    end

    let!(:smit_fgam) do
      Source::Bibtex.create!(
        bibtex_type: 'article',
        author: 'Smit, Franciscus Gerardus Albertus Maria and Jones, A.',
        year: 1964
      )
    end

    let!(:smit_no_given) do
      Source::Bibtex.create!(bibtex_type: 'article', author: 'Smit', year: 1964)
    end

    let(:result) { candidates([{ authors: 'Smit, F.G.A.M.', year: '1964' }]).first }

    specify 'conflicting initials do not match' do
      expect(candidate_for(result, smit_b)[:first_author_initials_match])
        .to be false
    end

    specify 'initials agree with full given names' do
      expect(candidate_for(result, smit_fgam)[:first_author_initials_match])
        .to be true
    end

    specify 'a Source without given names is not compared' do
      expect(candidate_for(result, smit_no_given)[:first_author_initials_match])
        .to be_nil
    end

    specify 'a row without initials is not compared' do
      r = candidates([{ authors: 'Smit', year: '1964' }]).first
      expect(candidate_for(r, smit_b)[:first_author_initials_match]).to be_nil
    end

    specify 'fewer initials agree with more' do
      r = candidates([{ authors: 'Smit, F.', year: '1964' }]).first
      expect(candidate_for(r, smit_fgam)[:first_author_initials_match]).to be true
    end

    specify 'any shared initial agrees, e.g. a later given name' do
      jordan = Source::Bibtex.create!(
        bibtex_type: 'article',
        author: 'Jordan, Heinrich Ernst Karl and Rothschild, Nathaniel Charles',
        year: 1923
      )
      r = candidates([{ authors: 'Jordan, K. & N.C. Rothschild', year: '1923' }])
      expect(candidate_for(r.first, jordan)[:first_author_initials_match])
        .to be true
    end

    specify 'reports the Source initials' do
      expect(candidate_for(result, smit_fgam)[:source_first_author_initials])
        .to eq(%w{F G A M})
    end
  end

  context 'other fields' do
    let(:c) do
      candidate_for(
        candidates([{
          authors: 'Müller', year: '1990',
          title: 'Fleas of the Peromyscus of Indiana',
          journal: 'J Parasitology',
          volume: '96(2):285-298'
        }]).first,
        source
      )
    end

    specify 'title similarity' do
      expect(c[:title_similarity]).to eq(1.0)
    end

    specify 'journal similarity' do
      expect(c[:journal_similarity]).to be_between(0.3, 1.0)
    end

    specify 'volume and first page' do
      expect(c[:volume_match]).to be true
      expect(c[:first_page_match]).to be true
    end

    context 'when the Source volume includes the issue' do
      def volume_match(source_volume, row_volume)
        source.update_column(:volume, source_volume)
        candidate_for(
          candidates([{
            authors: 'Müller', year: '1990', volume: row_volume
          }]).first,
          source
        )[:volume_match]
      end

      specify 'the same volume matches' do
        expect(volume_match('96(2)', '96(2):285-298')).to be true
        expect(volume_match(' 96 (2)', '96')).to be true
      end

      specify 'a different volume does not' do
        expect(volume_match('97(2)', '96(2):285-298')).to be false
      end
    end

    specify 'fields missing from the input are nil' do
      c = candidate_for(
        candidates([{ authors: 'Müller', year: '1990' }]).first, source
      )
      expect(c[:title_similarity]).to be_nil
      expect(c[:volume_match]).to be_nil
      expect(c[:doi_match]).to be_nil
    end
  end

  context 'agrees and disagrees' do
    let(:c) do
      candidate_for(
        candidates([{ authors: 'Müller', year: '1990', volume: '12' }]).first,
        source
      )
    end

    specify 'lists the fields that agree' do
      expect(c[:agrees]).to contain_exactly(:authors, :year)
    end

    specify 'lists the fields compared that do not agree' do
      expect(c[:disagrees]).to eq([:volume])
    end

    specify 'a field not compared is in neither' do
      expect(c[:agrees] + c[:disagrees]).not_to include(:title, :doi)
    end
  end

  context 'corroborated' do
    # Both Sources are by Müller, within the year window of 1992, so they're
    # gathered for each row here; neither has the same year. The first author
    # agrees, so one more agreeing field corroborates.
    context 'when the first author agrees' do
      def corroborated(row)
        r = candidates([{ authors: 'Müller', year: '1992', **row }]).first
        [source, other_source].map { |s| candidate_for(r, s)[:corroborated] }
      end

      specify 'not by the authors alone' do
        expect(corroborated({})).to eq([false, false])
      end

      specify 'not when other fields are compared but disagree' do
        expect(
          corroborated(title: 'A monograph of the moths', volume: '12')
        ).to eq([false, false])
      end

      specify 'by the same year' do
        expect(corroborated(year: '1991')).to eq([false, true])
      end

      specify 'by a similar journal' do
        expect(corroborated(journal: 'Journal of Parasitology'))
          .to eq([true, false])
      end

      specify 'by the same volume' do
        expect(corroborated(volume: '96')).to eq([true, false])
      end

      specify 'by the same first page' do
        expect(corroborated(pages: '285-298')).to eq([true, false])
      end

      specify 'within one edit' do
        r = candidates([{ authors: 'Müler', year: '1991' }]).first
        expect(candidate_for(r, other_source)[:corroborated]).to be true
      end
    end

    # `Smith` is the Source's third author, not its first.
    context 'when the first author does not agree' do
      def corroborated(row)
        r = candidates([{ authors: 'Smith', **row }]).first
        candidate_for(r, source)[:corroborated]
      end

      specify 'not by one field' do
        expect(corroborated(year: '1990')).to be false
        expect(corroborated(year: '1992', volume: '96')).to be false
      end

      specify 'by two fields' do
        expect(corroborated(year: '1990', volume: '96')).to be true
        expect(corroborated(year: '1992', volume: '96', pages: '285'))
          .to be true
      end

      specify 'by a similar title alone' do
        expect(
          corroborated(
            year: '1992', title: 'Fleas of the Peromyscus of Indiana'
          )
        ).to be true
      end

      specify 'not by a title only somewhat similar' do
        expect(corroborated(year: '1992', title: 'Fleas of Ohio')).to be false
      end

      specify 'by the same DOI alone' do
        expect(corroborated(year: '1992', doi: '10.1645/ge-2251.1')).to be true
      end
    end
  end

  context 'doi' do
    specify 'matches with no author or year' do
      c = candidate_for(
        candidates([{ doi: '10.1645/ge-2251.1' }]).first, source
      )
      expect(c[:doi_match]).to be true
    end
  end

  context 'verbatim' do
    specify 'finds the Source' do
      r = candidates([{
        verbatim: 'Muller, J., van der Merwe, A. & Smith, B. 1990. Fleas ' \
          'of the Peromyscus of Indiana. J. Parasitology 96(2): 285-298.'
      }]).first
      c = candidate_for(r, source)
      expect(r[:candidates].first[:source].id).to eq(source.id)
      expect(c[:volume_match]).to be true
      expect(c[:title_similarity]).to be > 0.8
    end

    specify 'with no parseable year or author, falls back to text' do
      r = candidates([{
        verbatim: 'Fleas of the Peromyscus of Indiana. J. Parasitology'
      }]).first
      expect(candidate_for(r, source)).to be_truthy
    end
  end

  context 'when more Sources match than are gathered' do
    before { stub_const('Match::Source::Gather::GATHER_LIMIT', 1) }

    specify 'prefers Sources whose first author is the row\'s' do
      co_authored = Source::Bibtex.create!(
        bibtex_type: 'article',
        author: 'Smith, A. and Müller, J.',
        year: 1990,
        title: 'Ticks of Ohio and Kentucky'
      )

      # The title partly agrees with the co-authored Source, so only the
      # first author tips it.
      r = candidates(
        [{ authors: 'Müller, J.', year: '1990', title: 'Ticks of Ohio' }]
      ).first
      expect(candidate_for(r, source)).to be_truthy
      expect(candidate_for(r, co_authored)).to be_nil
    end

    specify 'prefers Sources in the row\'s journal' do
      in_zootaxa = Source::Bibtex.create!(
        bibtex_type: 'article',
        author: 'Müller, J.',
        year: 1990,
        title: 'In Zootaxa',
        journal: 'Zootaxa'
      )

      r = candidates(
        [{ authors: 'Müller, J.', year: '1990', journal: 'Zootaxa' }]
      ).first
      expect(candidate_for(r, in_zootaxa)).to be_truthy
      expect(candidate_for(r, source)).to be_nil
    end

    specify 'breaks ties the same way every time' do
      tied = 3.times.map { |i|
        Source::Bibtex.create!(
          bibtex_type: 'article', author: 'Weber, K.', year: 2001,
          title: "Tied #{i}"
        )
      }

      ids = 3.times.map {
        candidates([{ authors: 'Weber', year: '2001' }])
          .first[:candidates].map { |c| c[:source].id }
      }
      expect(ids.uniq).to eq([[tied.map(&:id).min]])
    end

    specify 'compares the journal to the Source\'s serial' do
      serial = Serial.create!(name: 'Zootaxa')
      in_zootaxa = Source::Bibtex.create!(
        bibtex_type: 'article',
        author: 'Müller, J.',
        year: 1990,
        title: 'In Zootaxa',
        serial:
      )

      r = candidates(
        [{ authors: 'Müller, J.', year: '1990', journal: 'Zootaxa' }]
      ).first
      expect(candidate_for(r, in_zootaxa)).to be_truthy
    end
  end

  context 'a DOI on several Sources' do
    # A case variant gets past the uniqueness validation.
    let!(:copy) do
      Source::Bibtex.create!(
        bibtex_type: 'article', author: 'Müller, J.', year: 1990,
        title: 'Fleas of the Peromyscus of Indiana',
        doi: '10.1645/ge-2251.1'
      )
    end

    specify 'gathers every one' do
      r = candidates([{ doi: '10.1645/GE-2251.1' }]).first
      expect(r[:candidates].map { |c| c[:source].id })
        .to contain_exactly(source.id, copy.id)
    end

    specify 'limit_to_project gathers only the project\'s' do
      r = candidates(
        [{ doi: '10.1645/GE-2251.1' }], limit_to_project: true
      ).first
      expect(r[:candidates].map { |c| c[:source].id }).to eq([source.id])
    end
  end

  specify 'a volume label is not part of the volume' do
    r = candidates(
      [{ authors: 'Müller', year: '1990', volume: 'Vol. 96' }]
    ).first
    expect(candidate_for(r, source)[:volume_match]).to be true
  end

  context 'matched author counts, per max edits' do
    def counts(authors)
      candidate_for(
        candidates([{ authors:, year: '1990' }]).first, source
      )[:matched_author_counts]
    end

    specify 'row authors found in the Source' do
      expect(counts('Müller & Smith')).to eq([2, 2, 2, 2])
    end

    specify 'misspellings are found once enough edits are allowed' do
      expect(counts('Mueller & Smyth')).to eq([0, 2, 2, 2])
    end

    specify 'each Source author pairs with one row author' do
      expect(counts('Müller, Müller & Smith')).to eq([2, 2, 2, 2])
    end

    # With 1 edit, Smith is close to both Source authors, Smyth only to Smyth:
    # pairing Smith with the first close one (Smyth) would leave Smyth
    # nothing, so Smith has to move to Smit.
    specify 'a row author moves to another Source author to free one' do
      smyth_smit = Source::Bibtex.create!(
        bibtex_type: 'article', author: 'Smyth, A. and Smit, B.',
        year: 1990, title: 'Smyth and Smit'
      )
      r = candidates([{ authors: 'Smith & Smyth', year: '1990' }]).first
      expect(candidate_for(r, smyth_smit)[:matched_author_counts])
        .to eq([1, 2, 2, 2])
    end
  end

  specify 'a Source author BibTeX can\'t parse has no initials' do
    allow(BibTeX::Names).to receive(:parse).and_return(nil)
    r = candidates([{ authors: 'Müller, J.', year: '1990' }]).first
    expect(candidate_for(r, source)[:source_first_author_initials]).to eq([])
  end

  context 'project scope' do
    specify 'all Sources by default, flagging those in the project' do
      r = candidates([{ authors: 'Müller', year: '1990' }]).first
      expect(candidate_for(r, source)[:in_project]).to be true
      expect(candidate_for(r, other_source)[:in_project]).to be false
    end

    specify 'limit_to_project' do
      r = candidates(
        [{ authors: 'Müller', year: '1990' }], limit_to_project: true
      ).first
      expect(candidate_for(r, other_source)).to be_nil
      expect(candidate_for(r, source)).to be_truthy
    end
  end
end
