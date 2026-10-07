require 'rails_helper'

describe Match::Source::InputRow do

  context '.surnames' do
    # Author strings as they come in from real match lists.
    {
      'Ritzi, C.M. & J.O. Whitaker, Jr.' => %w{Ritzi Whitaker},
      '<html>Ritzi, C.M. & <b>J.O. Whitaker, Jr.</b></html>' =>
        %w{Ritzi Whitaker},
      'Good, N.E.' => %w{Good},
      'Smit, F.G.A.M.' => %w{Smit},
      'Abbot, P., A.E. Aviles, L. Eller & L.A. Durden' =>
        %w{Abbot Aviles Eller Durden},
      'Acosta, R, J.A. Fernandez, & J.Falcon-Ordaz' =>
        %w{Acosta Fernandez Falcon-Ordaz},
      'Abreu, M.H. (Traub & Starcke)' => %w{Abreu},
      'Ayala-Barajas, R., et al.' => %w{Ayala-Barajas},
      'Acosta, R..' => %w{Acosta},
      # Source#cached_author_string style
      'Huang, Liu, Chen, Chen, Li & Hu' => %w{Huang Liu Chen Chen Li Hu},
      'Emery, Emery & Popple' => %w{Emery Emery Popple},
      'Creão-Duarte & Sakakibara' => %w{Creão-Duarte Sakakibara},
      'van der Merwe, A. & B. Smith' => ['van der Merwe', 'Smith'],
      'Smith and Jones' => %w{Smith Jones},
      'Wang, Yiguan, et. al.' => %w{Wang Yiguan},
      'Trolle, L. & J-K. Jensen' => %w{Trolle Jensen},
      'Wu, Y-L., S-F. Hu' => %w{Wu Hu},
      'Amin, O.M./1976' => %w{Amin},
      'Huang, g. et al.' => %w{Huang},
      'Rahelinirina, S, M . Harimalala' => %w{Rahelinirina Harimalala},
      'Guerra, A.S., KB.Agwanda' => %w{Guerra Agwanda},
      'Dittmar, K. de la Cruz & M.F. Whiting' =>
        ['Dittmar', 'de la Cruz', 'Whiting'],
      '' => [],
      nil => []
    }.each do |author_string, expected|
      specify author_string.inspect do
        expect(Match::Source::InputRow.surnames(author_string)).to eq(expected)
      end
    end
  end

  context '.fold' do
    specify 'removes diacritics, case, and non-letters' do
      expect(Match::Source::InputRow.fold('Creão-Duarte')).to eq('creaoduarte')
      expect(Match::Source::InputRow.fold('De Long')).to eq('delong')
      expect(Match::Source::InputRow.fold('Müller')).to eq('muller')
    end
  end

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
      '100(2)' => ['100', nil]
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
