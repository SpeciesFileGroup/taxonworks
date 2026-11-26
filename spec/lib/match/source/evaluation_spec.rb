require 'rails_helper'

describe Match::Source::Evaluation, type: :model do
  let(:input) do
    Match::Source::InputRow.new(
      authors: 'Ritzi, C.M. & J.O. Whitaker', year: '2003', title: 'Fleas',
      volume: '96'
    )
  end

  # A corroborated candidate agreeing on everything the row has, both row
  # authors spelled the same, as from Match::Source::Candidates#call.
  def candidate(id = 1, **overrides)
    {
      source: Struct.new(:id).new(id),
      in_project: false,
      agrees: [:year, :authors, :title, :volume],
      disagrees: [],
      corroborated: true,
      first_author_distance: 0,
      author_distances: [0, 0],
      matched_author_counts: [2, 2, 2, 2]
    }.merge(overrides)
  end

  def evaluation(candidates, row = input)
    Match::Source::Evaluation.new({ index: 0, input: row, candidates: })
  end

  def qualifies?(row = input, **overrides)
    c = candidate(**overrides)
    evaluation([c], row).qualifies?(c)
  end

  context '#qualifies?' do
    specify 'when corroborated and nothing disagrees' do
      expect(qualifies?).to be true
    end

    specify 'not when not corroborated' do
      expect(qualifies?(corroborated: false)).to be false
    end

    specify 'not when a required field disagrees' do
      expect(qualifies?(disagrees: [:volume])).to be false
    end

    specify 'when only the journal disagrees' do
      expect(qualifies?(disagrees: [:journal])).to be true
    end

    specify 'when the DOI agrees, whatever disagrees' do
      expect(
        qualifies?(agrees: [:doi], disagrees: [:year], corroborated: true)
      ).to be true
    end

    context 'authors' do
      specify 'when the first author is one edit off' do
        expect(
          qualifies?(first_author_distance: 1, author_distances: [1, 0])
        ).to be true
      end

      specify 'when another row author is one edit off' do
        expect(qualifies?(author_distances: [0, 1])).to be true
      end

      specify 'not when a row author is two edits off' do
        expect(
          qualifies?(
            author_distances: [0, 2], matched_author_counts: [1, 1, 2, 2]
          )
        ).to be false
      end

      specify 'not when the first author\'s initials share no letter' do
        expect(qualifies?(first_author_initials_match: false)).to be false
      end

      specify 'not when a row author is not in the Source' do
        expect(
          qualifies?(author_distances: [0, 4], matched_author_counts: [1] * 4)
        ).to be false
      end

      # Both row authors are closest to the same Source author.
      specify 'not when two row authors pair with one Source author' do
        expect(qualifies?(matched_author_counts: [1] * 4)).to be false
      end

      specify 'not required when the row has none' do
        row = Match::Source::InputRow.new(year: '2003', title: 'Fleas')
        expect(qualifies?(row, agrees: [:year, :title])).to be true
      end
    end
  end

  context '#status and #match' do
    specify 'empty for an empty row' do
      e = evaluation([], Match::Source::InputRow.new(verbatim: ' '))
      expect([e.status, e.match]).to eq([:empty, nil])
    end

    specify 'unmatched with no candidates' do
      e = evaluation([])
      expect([e.status, e.match]).to eq([:unmatched, nil])
    end

    specify 'unmatched when none qualify' do
      e = evaluation([candidate(disagrees: [:year])])
      expect([e.status, e.match]).to eq([:unmatched, nil])
    end

    specify 'matched when one qualifies' do
      a = candidate(1)
      e = evaluation([a, candidate(2, disagrees: [:volume])])
      expect([e.status, e.match]).to eq([:matched, a])
    end

    specify 'ambiguous when several qualify' do
      e = evaluation([candidate(1), candidate(2)])
      expect([e.status, e.match]).to eq([:ambiguous, nil])
    end

    specify 'matched by the only agreeing DOI, whatever disagrees' do
      b = candidate(2, agrees: [:doi], disagrees: [:volume, :year])
      e = evaluation([candidate(1), b])
      expect([e.status, e.match]).to eq([:matched, b])
    end

    specify 'ambiguous when several share the DOI' do
      e = evaluation(
        [candidate(1, agrees: [:doi]), candidate(2, agrees: [:doi])]
      )
      expect([e.status, e.match]).to eq([:ambiguous, nil])
    end

    context 'when several qualify' do
      specify 'matched by the only one in the project' do
        b = candidate(2, in_project: true)
        e = evaluation([candidate(1), b, candidate(3)])
        expect([e.status, e.match]).to eq([:matched, b])
      end

      specify 'ambiguous when several are in the project' do
        e = evaluation(
          [candidate(1, in_project: true), candidate(2, in_project: true)]
        )
        expect([e.status, e.match]).to eq([:ambiguous, nil])
      end

      specify 'matched by the only one in the project among a shared DOI' do
        b = candidate(2, agrees: [:doi], in_project: true)
        e = evaluation([candidate(1, agrees: [:doi]), b])
        expect([e.status, e.match]).to eq([:matched, b])
      end

      specify 'not matched by one in the project that doesn\'t qualify' do
        e = evaluation(
          [
            candidate(1), candidate(2),
            candidate(3, in_project: true, disagrees: [:year])
          ]
        )
        expect([e.status, e.match]).to eq([:ambiguous, nil])
      end
    end
  end

  context '#listed' do
    specify 'the corroborated candidates, in order' do
      a, c = candidate(1), candidate(3, disagrees: [:volume])
      e = evaluation([a, candidate(2, corroborated: false), c])
      expect(e.listed).to eq([a, c])
    end

    specify 'the match first' do
      a = candidate(1, disagrees: [:volume])
      b = candidate(2)
      expect(evaluation([a, b]).listed).to eq([b, a])
    end
  end
end
