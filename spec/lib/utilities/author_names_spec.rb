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
      # Source#cached style: a particle written after the initials belongs
      # to the surname before them.
      'León, J.H.de & Morgan, D.J.W.' => ['de León', 'Morgan'],
      'Veen, J.C.van & Wijk, M.L.E.van' => ['van Veen', 'van Wijk'],
      'Silva, I.M.da, Silva, R.O., Andrade, G.S.' =>
        ['da Silva', 'Silva', 'Andrade'],
      'Ralec, A.le & Wajnberg, E.' => ['le Ralec', 'Wajnberg'],
      # A particle followed by an initial is a given name's: Franz von
      # Paula Schrank, Maria das Graças Fonseca.
      'Schrank, F.von P.' => ['Schrank'],
      'Fonseca, M.das G., Auad, A.M.' => ['Fonseca', 'Auad'],
      'Veloso, R.von dos S., Castro, A.C.R.de' => ['Veloso', 'de Castro'],
      'de Souza, M.dos S., do Nascimento, I.N.' => ['de Souza', 'do Nascimento'],
      'Burckhardt, D. & de Queiroz, D.L.' => ['Burckhardt', 'de Queiroz'],
      'Centeno, E., de Mello, F.de A.G. & Zefa, E.' =>
        ['Centeno', 'de Mello', 'Zefa'],
      'Walt, A.van der, Plessis, H.du & Berg, J.van den' =>
        ['van der Walt', 'du Plessis', 'van den Berg'],
      # Particles in the given names too: only a run at the end is the
      # surname's (Jean-Baptiste ... de Monet de Lamarck).
      'Lamarck, J.B.P.A.de M. de' => ['de Lamarck'],
      'Correia, M.de L.M.de A.' => ['Correia'],
      'Liang, G.-qiu, Chen, Y.-Q., Li, Q. & Chen, Y.-L.' =>
        %w{Liang Chen Li Chen},
      'Akimoto, S.-ichi' => %w{Akimoto},
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

  context '.initials' do
    {
      'F.G.A.M.' => %w{F G A M},
      'Franciscus Gerardus Albertus Maria' => %w{F G A M},
      'C. M.' => %w{C M},
      'J.-P.' => %w{J P},
      'Jean-Pierre' => %w{J P},
      'Y-L' => %w{Y L},
      'Ch.' => %w{C},
      'G.-qiu' => %w{G Q},
      'KB.' => %w{K B},
      'g.' => %w{G},
      'Émile' => %w{E},
      '' => [],
      nil => []
    }.each do |given_names, expected|
      specify given_names.inspect do
        expect(Utilities::AuthorNames.initials(given_names)).to eq(expected)
      end
    end
  end

  context '.first_author_initials' do
    # Author strings as they come in from real match lists.
    {
      'Smit, F.G.A.M.' => %w{F G A M},
      'Smit F.G.A.M.' => %w{F G A M},
      'Ritzi, C.M. & J.O. Whitaker, Jr.' => %w{C M},
      '<html>Ritzi, C.M. & <b>J.O. Whitaker, Jr.</b></html>' => %w{C M},
      'C.M. Ritzi & J.O. Whitaker' => %w{C M},
      'Abbot, P., A.E. Aviles, L. Eller & L.A. Durden' => %w{P},
      'Acosta, R, J.A. Fernandez, & J.Falcon-Ordaz' => %w{R},
      'Wu, Y-L., S-F. Hu' => %w{Y L},
      'Ayala-Barajas, R., et al.' => %w{R},
      'Huang, g. et al.' => %w{G},
      'León, J.H.de & Morgan, D.J.W.' => %w{J H},
      'Liang, G.-qiu, Chen, Y.-Q.' => %w{G Q},
      # Comma-separated surnames, no initials.
      'Huang, Liu, Chen, Chen, Li & Hu' => [],
      # Ambiguous: K. may be Dittmar's or de la Cruz's.
      'Dittmar, K. de la Cruz & M.F. Whiting' => [],
      'Amyot et Serville' => [],
      'Smit' => [],
      '' => [],
      nil => []
    }.each do |author_string, expected|
      specify author_string.inspect do
        expect(Utilities::AuthorNames.first_author_initials(author_string))
          .to eq(expected)
      end
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
