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
    before { stub_const('Match::Source::Candidates::GATHER_LIMIT', 1) }

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
