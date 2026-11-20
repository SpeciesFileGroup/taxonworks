require 'rails_helper'

describe Match::Source::InputRow do

  context 'structured fields' do
    let(:row) do
      Match::Source::InputRow.new(
        authors: '<html>Ritzi, C.M. & <b>J.O. Whitaker, Jr.</b></html>',
        year: '2003',
        journal: 'Northeastern Naturalist',
        volume: '10(2):149-158'
      )
    end

    specify 'year' do
      expect(row.year).to eq(2003)
    end

    specify 'surnames' do
      expect(row.surnames).to eq(%w{Ritzi Whitaker})
    end

    specify 'volume, issue, and pages are split out of a combined field' do
      expect(row.volume).to eq('10')
      expect(row.first_page).to eq('149')
    end

    specify 'journal' do
      expect(row.journal).to eq('Northeastern Naturalist')
    end

    specify 'year suffix' do
      r = Match::Source::InputRow.new(authors: 'Nast', year: '1936a')
      expect(r.year).to eq(1936)
      expect(r.year_suffix).to eq('a')
    end

    specify 'non-numeric year' do
      expect(Match::Source::InputRow.new(year: 'n.d.').year).to be_nil
    end

    {
      '96(2):285-298' => ['96', '285'],
      '3(1-4):135-151' => ['3', '135'],
      '89: 39-53' => ['89', '39'],
      '37' => ['37', nil],
      '1638' => ['1638', nil],
      'pp. 357-370' => [nil, '357'],
      '100(2)' => ['100', nil],
      'Vol. 10' => ['10', nil],
      'Volume 10(2): 5-9' => ['10', '5'],
      'vol.10' => ['10', nil],
      '10, 149-158' => ['10', nil]
    }.each do |volume_string, (volume, first_page)|
      specify "volume #{volume_string.inspect}" do
        r = Match::Source::InputRow.new(volume: volume_string)
        expect([r.volume, r.first_page]).to eq([volume, first_page])
      end
    end

    specify 'explicit pages win over pages parsed from volume' do
      r = Match::Source::InputRow.new(volume: '96(2):285-298', pages: '286-298')
      expect(r.first_page).to eq('286')
    end

    specify 'doi is normalized' do
      r = Match::Source::InputRow.new(doi: 'https://doi.org/10.1645/GE-2251.1')
      expect(r.doi).to eq('10.1645/ge-2251.1')
    end

    {
      '10.1645/GE-2251.1)' => '10.1645/ge-2251.1',
      'https://doi.org/10.1016/0001(99)00012-X' => '10.1016/0001(99)00012-x'
    }.each do |doi, normalized|
      specify "doi #{doi.inspect} loses only an unbalanced bracket" do
        expect(Match::Source::InputRow.new(doi:).doi).to eq(normalized)
      end
    end
  end

  context 'HTML entities, as in Source#cached' do
    specify 'are decoded in structured fields' do
      r = Match::Source::InputRow.new(
        authors: 'Drees, B.M. &amp; Rice, M.E.',
        title: 'Soybean &quot;pests&quot; &lt;Texas&gt;'
      )
      expect(r.surnames).to eq(%w{Drees Rice})
      expect(r.title).to eq('Soybean "pests" <Texas>')
    end

    specify 'are decoded in verbatim' do
      r = Match::Source::InputRow.new(
        verbatim: 'Drees, B.M. &amp; Rice, M.E. (1990a) Population ' \
          'dynamics. <i>Southwestern Entomologist</i>, 15(1), 49–56.'
      )
      expect(r.surnames).to eq(%w{Drees Rice})
      expect(r.year).to eq(1990)
    end

    specify 'numeric entities' do
      r = Match::Source::InputRow.new(authors: 'Kone&#269;n&#253;, A.')
      expect(r.surnames).to eq(['Konečný'])
    end
  end

  context 'first author initials' do
    specify 'from structured authors' do
      r = Match::Source::InputRow.new(authors: 'Smit, F.G.A.M.')
      expect(r.first_author_initials).to eq(%w{F G A M})
    end

    specify 'from verbatim' do
      r = Match::Source::InputRow.new(verbatim: 'Smit, F.G.A.M. 1964. Fleas.')
      expect(r.first_author_initials).to eq(%w{F G A M})
    end
  end

  context 'verbatim' do
    let(:row) do
      Match::Source::InputRow.new(
        verbatim: 'Acosta, R. & Morrone, J.J. 2005. Two new species of ' \
          'Strepsylla. Zootaxa 1027: 55-63. doi:10.11646/zootaxa.1027.1.5'
      )
    end

    specify 'year' do
      expect(row.year).to eq(2005)
    end

    specify 'surnames come from before the year' do
      expect(row.surnames).to eq(%w{Acosta Morrone})
    end

    specify 'volume and first page' do
      expect(row.volume).to eq('1027')
      expect(row.first_page).to eq('55')
    end

    specify 'doi' do
      expect(row.doi).to eq('10.11646/zootaxa.1027.1.5')
    end

    specify 'the remainder is kept as text to compare against' do
      expect(row.text).to include('Two new species of Strepsylla')
      expect(row.text).to include('Zootaxa')
    end

    {
      'Horváth, G. (1897a) Description d\'Hémiptères nouveaux. Revue ' \
        'Française d\'Entomologie, 16, 81–97.' => ['16', '81'],
      'Stroiński, A. & Szwedo, J. (2008a) Thionia douglundbergi sp. nov. ' \
        'Annales Zoologici, Warszaw, 58(3), 529–536.' => ['58', '529'],
      'Smith, J. (1990) Title. Journal, 12, pp. 5-9.' => ['12', '5'],
      # A comma-separated number with no page range is not taken as volume.
      'Smith, J. (1990) Notes, 3, on things. Journal.' => [nil, nil]
    }.each do |verbatim, (volume, first_page)|
      specify "volume and first page, comma separated: #{verbatim[0, 30]}" do
        r = Match::Source::InputRow.new(verbatim:)
        expect([r.volume, r.first_page]).to eq([volume, first_page])
      end
    end

    {
      'Smith, J. (2005) Title. Zootaxa 1027: 55-63 ' \
        '(doi:10.11646/zootaxa.1027.1.5)' => '10.11646/zootaxa.1027.1.5',
      'Smith, J. (2005) Title. Zootaxa 1027: 55-63. ' \
        '[https://doi.org/10.11646/zootaxa.1027.1.5].' =>
        '10.11646/zootaxa.1027.1.5',
      'Smith, J. (2005) Title. J. 1: 1-9. https://doi.org/10.1016/0001(99)0001-X' =>
        '10.1016/0001(99)0001-x'
    }.each do |verbatim, doi|
      specify "doi in brackets or as a link: #{verbatim[-40..]}" do
        r = Match::Source::InputRow.new(verbatim:)
        expect(r.doi).to eq(doi)
        expect(r.text).not_to match(/doi|[(\[]\s*\z|\A\s*[)\]]/i)
        expect(r.text).to start_with('Title.')
      end
    end

    specify 'year in parentheses' do
      r = Match::Source::InputRow.new(
        verbatim: 'Smit, F.G.A.M. (1953a) Am Mus Novitates 1638'
      )
      expect(r.year).to eq(1953)
      expect(r.year_suffix).to eq('a')
      expect(r.surnames).to eq(%w{Smit})
    end

    specify 'structured fields win over verbatim parsing' do
      r = Match::Source::InputRow.new(
        verbatim: 'Smit, F.G.A.M. 1953. Am Mus Novitates 1638', year: '1954'
      )
      expect(r.year).to eq(1954)
    end
  end

  specify '#empty?' do
    expect(Match::Source::InputRow.new(verbatim: '  ').empty?).to be true
    expect(Match::Source::InputRow.new(year: '1900').empty?).to be false
  end
end
