require 'rails_helper'

describe Utilities::AuthorNames do

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
      'Ritzi, Ch..' => %w{Ritzi},
      # Source#cached_author_string style
      'Huang, Liu, Chen, Chen, Li & Hu' => %w{Huang Liu Chen Chen Li Hu},
      'Emery, Emery & Popple' => %w{Emery Emery Popple},
      'Creão-Duarte & Sakakibara' => %w{Creão-Duarte Sakakibara},
      'van der Merwe, A. & B. Smith' => ['van der Merwe', 'Smith'],
      'Smith and Jones' => %w{Smith Jones},
      'Amyot et Serville' => %w{Amyot Serville},
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
        expect(Utilities::AuthorNames.surnames(author_string)).to eq(expected)
      end
    end
  end

  context '.fold' do
    specify 'removes diacritics, case, and non-letters' do
      expect(Utilities::AuthorNames.fold('Creão-Duarte')).to eq('creaoduarte')
      expect(Utilities::AuthorNames.fold('De Long')).to eq('delong')
      expect(Utilities::AuthorNames.fold('Müller')).to eq('muller')
    end
  end

  context '.authorship_key' do
    # As TaxonWorks (#cached_author_year) and CoL write them.
    {
      'Funkhouser, 1927' =>
        { surnames: %w{funkhouser}, year: 1927, parenthesized: false },
      '(Walker, 1851)' =>
        { surnames: %w{walker}, year: 1851, parenthesized: true },
      'Tsaur & Hsu, 1991' =>
        { surnames: %w{tsaur hsu}, year: 1991, parenthesized: false },
      'Melichar, 1898 non Walker, 1851' =>
        { surnames: %w{melichar}, year: 1898, parenthesized: false },
      '(Uhler, 1896) non Walker, 1851' =>
        { surnames: %w{uhler}, year: 1896, parenthesized: true },
      'Remes Lenicov, 1973 non Fowler, 1895' =>
        { surnames: %w{remeslenicov}, year: 1973, parenthesized: false },
      'Horváth, 1899' =>
        { surnames: %w{horvath}, year: 1899, parenthesized: false },
      'Lam.' => nil,
      'Walker' => nil,
      '' => nil,
      nil => nil
    }.each do |authorship, expected|
      specify authorship.inspect do
        expect(Utilities::AuthorNames.authorship_key(authorship))
          .to eq(expected)
      end
    end
  end

  context '.same_authorship?' do
    let(:t) { Utilities::AuthorNames }
    let(:plain) { t.authorship_key('Walker, 1851') }
    let(:parenthesized) { t.authorship_key('(Walker, 1851)') }

    specify 'ignores parentheses by default' do
      expect(t.same_authorship?(plain, parenthesized)).to be true
    end

    specify 'compares parentheses when asked to' do
      expect(t.same_authorship?(plain, parenthesized, parentheses: true))
        .to be false
    end

    specify 'a different year differs' do
      expect(t.same_authorship?(plain, t.authorship_key('Walker, 1857')))
        .to be false
    end

    specify 'a missing key is never the same' do
      expect(t.same_authorship?(nil, nil)).to be false
      expect(t.same_authorship?(plain, nil)).to be false
    end
  end

end
