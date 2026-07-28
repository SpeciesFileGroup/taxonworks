require 'rails_helper'

describe Utilities::PageMap do

  let(:map_class) { Utilities::PageMap }
  let(:print_page_class) { Utilities::PageMap::PrintPage }
  let(:range_set_class) { Utilities::PageMap::RangeSet }
  let(:pair_class) { Utilities::PageMap::Pair }

  # --------------------------------------------------------------------------
  # Scenarios, the fixtures called for by the prompt
  # --------------------------------------------------------------------------

  # (a) a scan of a journal article: 20 document pages, printed 300 through 319
  let(:offset_scan) {
    map_class.unpack(
      [
        { 'document' => [{ 'from' => 1, 'to' => 20 }],
          'print' => [{ 'from' => 300, 'to' => 319 }] }
      ]
    )
  }

  # (b) roman front matter followed by an arabic body
  let(:front_matter) {
    map_class.unpack(
      [
        { 'document' => [{ 'from' => 1, 'to' => 4 }],
          'print' => [{ 'from' => 'i', 'to' => 'iv', 'roman' => true }] },
        { 'document' => [{ 'from' => 5, 'to' => 304 }],
          'print' => [{ 'from' => 1, 'to' => 300 }] }
      ]
    )
  }

  # (c) a two-up scan, one document page holding two printed pages
  let(:two_up) {
    map_class.unpack(
      [
        { 'document' => [1], 'print' => [300, 301], 'alignment' => 'collective' },
        { 'document' => [2], 'print' => [302, 303], 'alignment' => 'collective' }
      ]
    )
  }

  # (d) a plate section, labels generated from a template
  let(:plates) {
    map_class.unpack(
      [
        { 'document' => [{ 'from' => 1, 'to' => 4 }],
          'print' => [{ 'from' => 1, 'to' => 4 }] },
        { 'document' => [{ 'from' => 5, 'to' => 8 }],
          'print' => [{ 'template' => 'Plate %d', 'from' => 1, 'to' => 4 }] }
      ]
    )
  }

  # (e) a map keyed by remote page identifiers rather than integers
  let(:remote) {
    map_class.unpack(
      [
        { 'document' => ['https://www.biodiversitylibrary.org/page/1001'], 'print' => ['10'] },
        { 'document' => ['https://www.biodiversitylibrary.org/page/1002'], 'print' => ['11'] },
        { 'document' => ['https://www.biodiversitylibrary.org/page/1003'], 'print' => ['12'] }
      ]
    )
  }

  # (f) a sparse map, only two pages known
  let(:sparse) {
    map_class.unpack('1' => '300', '5' => '304')
  }

  # (g) a fold-out, one printed page across several contiguous document pages
  let(:fold_out) {
    map_class.unpack(
      [
        { 'document' => [{ 'from' => 40, 'to' => 42 }],
          'print' => ['12'],
          'alignment' => 'collective' }
      ]
    )
  }

  # (h) a scattered printed page, discontiguous document pages
  let(:scattered) {
    map_class.unpack(
      [
        { 'document' => [1, 4, { 'from' => 5, 'to' => 10 }],
          'print' => ['4'],
          'alignment' => 'collective' }
      ]
    )
  }

  # (i) the same label printed on two unrelated document pages
  let(:duplicated_label) {
    map_class.unpack(
      [
        { 'document' => [{ 'from' => 1, 'to' => 3 }], 'print' => [{ 'from' => 1, 'to' => 3 }] },
        { 'document' => [{ 'from' => 4, 'to' => 6 }], 'print' => [{ 'from' => 1, 'to' => 3 }] }
      ]
    )
  }

  let(:all_fixtures) {
    [offset_scan, front_matter, two_up, plates, remote, sparse, fold_out,
     scattered, duplicated_label]
  }

  # --------------------------------------------------------------------------

  describe Utilities::PageMap::PrintPage do

    specify 'preserves the label verbatim' do
      expect(print_page_class.new('  XI ').label).to eq('  XI ')
    end

    specify 'an integer label has a numeric value' do
      page = print_page_class.new('300')

      expect(page.integer?).to be_truthy
      expect(page.numeric_value).to eq(300)
    end

    specify 'every other label is a string with no numeric value' do
      %w{xi Plate\ 12 12a A-3 S15 cover https://example.org/1 [12]}.each do |label|
        page = print_page_class.new(label)

        expect(page.integer?).to be_falsey
        expect(page.numeric_value).to be_nil
      end
    end

    specify 'a roman numeral is a string, not a number' do
      expect(print_page_class.new('xi').numeric_value).to be_nil
      expect(print_page_class.new('xi')).not_to eq(print_page_class.new('11'))
    end

    specify 'identity folds case and whitespace' do
      expect(print_page_class.new('XI')).to eq(print_page_class.new('xi'))
      expect(print_page_class.new('Plate  1')).to eq(print_page_class.new('plate 1'))
      expect(print_page_class.new(' 12 ')).to eq(print_page_class.new('12'))
    end

    specify 'identity ignores leading zeros on integers' do
      expect(print_page_class.new('007')).to eq(print_page_class.new('7'))
      expect(print_page_class.new('007').label).to eq('007')
    end

    specify 'identity never matches a substring' do
      expect(print_page_class.new('30')).not_to eq(print_page_class.new('300'))
    end

    specify 'de-duplicates by identity' do
      pages = [print_page_class.new('XI'), print_page_class.new('xi'), print_page_class.new('7')]
      expect(pages.uniq.size).to eq(2)
    end

    specify 'sorts integers ascending, then strings lexically' do
      pages = [
        print_page_class.new('cover'),
        print_page_class.new('12'),
        print_page_class.new('2'),
        print_page_class.new('Plate 1')
      ].sort

      # Strings sort by their case-folded form, so 'cover' precedes 'Plate 1'.
      expect(pages.map(&:label)).to eq(['2', '12', 'cover', 'Plate 1'])
    end

    specify 'sorting is total over mixed labels' do
      labels = %w{9 xi 10 cover 2 Plate\ 3 007}
      pages = labels.map { |l| print_page_class.new(l) }

      expect { pages.sort }.not_to raise_error
      expect(pages.sort.size).to eq(labels.size)
    end

    specify 'exposes a hash' do
      expect(print_page_class.new('xi').to_h).to eq(
        'label' => 'xi', 'integer' => false, 'numeric_value' => nil
      )
    end
  end

  describe Utilities::PageMap::RangeSet do

    specify 'sizes without expanding' do
      set = range_set_class.build([{ 'from' => 1, 'to' => 900 }])
      expect(set.size).to eq(900)
      expect(set.single_member?).to be_truthy
    end

    specify 'flattens integer ranges' do
      expect(range_set_class.build([{ 'from' => 1, 'to' => 3 }, 9]).to_a).to eq([1, 2, 3, 9])
    end

    specify 'generates roman labels from a roman range' do
      set = range_set_class.build([{ 'from' => 'i', 'to' => 'v', 'roman' => true }])
      expect(set.to_a).to eq(%w{i ii iii iv v})
    end

    specify 'generates labels from a template range' do
      set = range_set_class.build([{ 'template' => 'Plate %d', 'from' => 1, 'to' => 3 }])
      expect(set.to_a).to eq(['Plate 1', 'Plate 2', 'Plate 3'])
    end

    specify 'honours step' do
      set = range_set_class.build([{ 'from' => 1, 'to' => 9, 'step' => 2 }])
      expect(set.to_a).to eq([1, 3, 5, 7, 9])
      expect(set.include?(4)).to be_falsey
      expect(set.include?(5)).to be_truthy
    end

    specify 'answers include? without expanding' do
      set = range_set_class.build([{ 'from' => 1, 'to' => 900 }])
      expect(set).not_to receive(:to_a)
      expect(set.include?(450)).to be_truthy
      expect(set.include?(901)).to be_falsey
    end

    specify 'canonicalize merges adjacent and overlapping members' do
      set = range_set_class.build([1, 4, { 'from' => 5, 'to' => 10 }]).canonicalize
      expect(set.as_json).to eq([1, { 'from' => 4, 'to' => 10 }])
      expect(set.to_a).to eq([1, 4, 5, 6, 7, 8, 9, 10])
    end

    specify 'canonicalize is idempotent' do
      once = range_set_class.build([9, 1, { 'from' => 2, 'to' => 4 }]).canonicalize
      expect(once.canonicalize.as_json).to eq(once.as_json)
    end

    specify 'refuses backwards ranges' do
      expect { range_set_class.build([{ 'from' => 10, 'to' => 1 }]) }
        .to raise_error(Utilities::PageMap::FormatError)
    end

    specify 'refuses unreadable members' do
      expect { range_set_class.build([{ 'to' => 1 }]) }
        .to raise_error(Utilities::PageMap::FormatError)
    end

    specify 'refuses a member declared roman whose bounds are not' do
      expect { range_set_class.build([{ 'from' => 'nope', 'to' => 'also nope', 'roman' => true }]) }
        .to raise_error(Utilities::PageMap::FormatError)
    end

    specify 'detects a roman range without the flag' do
      set = range_set_class.build([{ 'from' => 'i', 'to' => 'iii' }])
      expect(set.to_a).to eq(%w{i ii iii})
    end

    specify 'guards against absurd expansion' do
      set = range_set_class.build([{ 'from' => 1, 'to' => 10_000_000 }])
      expect { set.to_a }.to raise_error(Utilities::PageMap::ExpansionError)
    end
  end

  describe Utilities::PageMap::Pair do

    specify 'infers positional alignment when the sizes match' do
      pair = pair_class.build('document' => [{ 'from' => 1, 'to' => 3 }], 'print' => [7, 8, 9])

      expect(pair.alignment).to eq('positional')
      expect(pair.each_mapping.to_a.map { |dp, pp| [dp, pp.label] })
        .to eq([[1, '7'], [2, '8'], [3, '9']])
    end

    specify 'refuses to infer an alignment when the sizes differ' do
      expect { pair_class.build('document' => [1], 'print' => [7, 8]) }
        .to raise_error(Utilities::PageMap::AlignmentError)
    end

    specify 'accepts unequal sizes when collective is declared' do
      pair = pair_class.build('document' => [1], 'print' => [7, 8], 'alignment' => 'collective')

      expect(pair.each_mapping.to_a.map { |dp, pp| [dp, pp.label] })
        .to eq([[1, '7'], [1, '8']])
    end

    specify 'collective is a cartesian product' do
      pair = pair_class.build('document' => [1, 2], 'print' => [7, 8], 'alignment' => 'collective')

      expect(pair.each_mapping.to_a.size).to eq(4)
    end

    specify 'positional preserves author order, because that order is the mapping' do
      pair = pair_class.build('document' => [4, 1], 'print' => [70, 10], 'alignment' => 'positional')

      expect(pair.document.as_json).to eq([4, 1])
      expect(pair.each_mapping.to_a.map { |dp, pp| [dp, pp.label] })
        .to eq([[4, '70'], [1, '10']])
    end

    specify 'collective sorts, since member order carries no meaning there' do
      pair = pair_class.build('document' => [4, 1], 'print' => [70, 10], 'alignment' => 'collective')

      expect(pair.document.as_json).to eq([1, 4])
      expect(pair.print.as_json).to eq([10, 70])
    end

    specify 'collective merges only members that are genuinely adjacent' do
      pair = pair_class.build(
        'document' => [1, 2, { 'from' => 3, 'to' => 5 }, 9],
        'print' => ['7'],
        'alignment' => 'collective'
      )

      expect(pair.document.as_json).to eq([{ 'from' => 1, 'to' => 5 }, 9])
    end

    specify 'a pair with no print side is unmapped' do
      pair = pair_class.build('document' => [{ 'from' => 1, 'to' => 2 }])

      expect(pair.unmapped?).to be_truthy
      expect(pair.each_mapping.to_a).to eq([[1, nil], [2, nil]])
    end

    specify 'refuses an unknown alignment' do
      expect { pair_class.build('document' => [1], 'print' => [1], 'alignment' => 'sideways') }
        .to raise_error(Utilities::PageMap::FormatError)
    end

    specify 'refuses a pair with no document side' do
      expect { pair_class.build('print' => [1]) }
        .to raise_error(Utilities::PageMap::FormatError)
    end
  end

  describe '.unpack' do

    specify 'reads an empty map' do
      expect(map_class.unpack(nil).empty?).to be_truthy
      expect(map_class.new.empty?).to be_truthy
    end

    specify 'reads a JSON string' do
      expect(map_class.unpack(offset_scan.to_json)).to eq(offset_scan)
    end

    specify 'reads symbol keys' do
      map = map_class.unpack([{ document: [1], print: [300] }])
      expect(map.document_page('300')).to eq([1])
    end

    specify 'an Array is the packed form' do
      map = map_class.unpack([{ 'document' => [1], 'print' => ['300'] }])

      expect(map.pairs.size).to eq(1)
      expect(map.document_page('300')).to eq([1])
    end

    specify 'a Hash is the expanded form' do
      map = map_class.unpack(1 => '300')

      expect(map.pairs.size).to eq(1)
      expect(map.document_page('300')).to eq([1])
    end

    specify 'reads a JSON string of either form' do
      expect(map_class.unpack('[{"document":[1],"print":["300"]}]').document_page('300')).to eq([1])
      expect(map_class.unpack('{"1":"300"}').document_page('300')).to eq([1])
    end

    specify 'reads an empty array' do
      expect(map_class.unpack([]).empty?).to be_truthy
    end

    specify 'reads the plain expanded hash the requirements call for' do
      map = map_class.unpack('1' => '300', '2' => %w{301 302 xi})

      expect(map.print_page(1).map(&:label)).to eq(['300'])
      expect(map.print_page(2).map(&:label)).to eq(%w{301 302 xi})
      expect(map.document_page('302')).to eq([2])
    end

    specify 'reads a many-to-many expanded hash' do
      map = map_class.unpack('1' => %w{300 301}, '2' => ['301'])

      expect(map.document_page('301')).to eq([1, 2])
      expect(map.document_page('300')).to eq([1])
    end

    specify 'refuses what it cannot read' do
      expect { map_class.unpack(12) }.to raise_error(Utilities::PageMap::FormatError)
    end
  end

  describe '#pack' do

    specify 'a 900 page scan packs to one pair, not 900 keys' do
      map = map_class.unpack(
        [{ 'document' => [{ 'from' => 1, 'to' => 900 }],
                      'print' => [{ 'from' => 1, 'to' => 900 }] }]
      )

      expect(map.pack.size).to eq(1)
      expect(map.to_json.length).to be < 200
      expect(map.document_pages.size).to eq(900)
    end

    specify 'unpack(pack(m)) == m' do
      all_fixtures.each { |map| expect(map_class.unpack(map.pack)).to eq(map) }
    end

    specify 'pack is idempotent' do
      all_fixtures.each { |map| expect(map_class.unpack(map.pack).pack).to eq(map.pack) }
    end

    specify 'pack is lossless across alignment and multi-member sets' do
      packed = scattered.pack.first

      expect(packed['alignment']).to eq('collective')
      expect(packed['document']).to eq([1, { 'from' => 4, 'to' => 10 }])
      expect(packed['print']).to eq(['4'])
    end

    specify 'pack preserves verbatim labels' do
      map = map_class.unpack('1' => '[007]')

      expect(map.pack.first['print']).to eq(['[007]'])
      expect(map.label_for(1)).to eq('[007]')
    end

    specify 'packs to a bare array, with no wrapping object' do
      expect(offset_scan.pack).to be_an(Array)
      expect(offset_scan.to_json).to start_with('[')
      expect(JSON.parse(offset_scan.to_json)).to be_an(Array)
    end

    specify 'survives JSON with string keys only' do
      expect(map_class.unpack(JSON.parse(front_matter.to_json))).to eq(front_matter)
    end

    specify 'preserves pair order, which is meaningful' do
      map = map_class.unpack(
        [
          { 'document' => [{ 'from' => 1, 'to' => 3 }], 'print' => [{ 'from' => 1, 'to' => 3 }] },
          { 'document' => [2], 'print' => ['99'] }
        ]
      )

      expect(map.pack.map { |p| p['print'] }).to eq([[{ 'from' => 1, 'to' => 3 }], ['99']])
      expect(map_class.unpack(map.pack).pack).to eq(map.pack)
    end
  end

  describe '#to_h' do
    specify 'expands to document page => labels' do
      expect(sparse.to_h).to eq(1 => ['300'], 5 => ['304'])
    end

    specify 'expands a two-up scan' do
      expect(two_up.to_h).to eq(1 => %w{300 301}, 2 => %w{302 303})
    end
  end

  describe '#document_page' do

    specify 'resolves an offset scan' do
      expect(offset_scan.document_page('300')).to eq([1])
      expect(offset_scan.document_page('319')).to eq([20])
    end

    specify 'accepts an integer, a string or a PrintPage' do
      expect(offset_scan.document_page(300)).to eq([1])
      expect(offset_scan.document_page('300')).to eq([1])
      expect(offset_scan.document_page(print_page_class.new('300'))).to eq([1])
    end

    specify 'never substring matches' do
      map = map_class.unpack('1' => '300', '2' => '30')

      expect(map.document_page('30')).to eq([2])
      expect(map.document_page('300')).to eq([1])
      expect(map.document_page('0')).to eq([])
    end

    specify 'returns an empty array, never nil, when unknown' do
      expect(offset_scan.document_page('999')).to eq([])
      expect(offset_scan.document_page('nonsense')).to eq([])
    end

    specify 'resolves roman front matter by its label' do
      expect(front_matter.document_page('i')).to eq([1])
      expect(front_matter.document_page('IV')).to eq([4])
      expect(front_matter.document_page('1')).to eq([5])
    end

    specify 'resolves a fold-out to every document page it spans' do
      expect(fold_out.document_page('12')).to eq([40, 41, 42])
    end

    specify 'resolves a scattered page to a discontiguous set' do
      expect(scattered.document_page('4')).to eq([1, 4, 5, 6, 7, 8, 9, 10])
    end

    specify 'resolves a template generated label' do
      expect(plates.document_page('Plate 3')).to eq([7])
    end
  end

  describe 'a label printed on more than one document page' do

    specify 'is one printed page, not several' do
      expect(duplicated_label.print_pages.map(&:label)).to eq(%w{1 2 3})
      expect(duplicated_label.print_pages.size).to eq(3)
    end

    specify 'returns every document page bearing it' do
      expect(duplicated_label.document_page('1')).to eq([1, 4])
      expect(duplicated_label.document_page('2')).to eq([2, 5])
    end

    specify 'still reports its own label on each document page' do
      expect(duplicated_label.label_for(1)).to eq('1')
      expect(duplicated_label.label_for(4)).to eq('1')
    end

    specify 'collapses in the token projection' do
      expect(duplicated_label.page_tokens).to eq(%w{1 2 3})
    end

    specify 'is not a conflict, since the pairs do not overlap' do
      expect(duplicated_label.conflicts).to eq([])
    end
  end

  describe '#print_page' do

    specify 'returns PrintPages' do
      pages = offset_scan.print_page(1)

      expect(pages.size).to eq(1)
      expect(pages.first).to be_a(print_page_class)
      expect(pages.first.label).to eq('300')
    end

    specify 'returns several for a two-up page' do
      expect(two_up.print_page(1).map(&:label)).to eq(%w{300 301})
    end

    specify 'accepts a numeric string document page' do
      expect(offset_scan.print_page('1').map(&:label)).to eq(['300'])
    end

    specify 'returns an empty array when unknown' do
      expect(offset_scan.print_page(99)).to eq([])
    end

    specify 'resolves remote document pages' do
      expect(remote.print_page('https://www.biodiversitylibrary.org/page/1002').map(&:label))
        .to eq(['11'])
    end
  end

  describe '#label_for' do
    specify 'returns the first label' do
      expect(two_up.label_for(1)).to eq('300')
    end

    specify 'returns nil when unknown' do
      expect(two_up.label_for(99)).to be_nil
    end
  end

  describe '#each_page' do
    specify 'yields document pages in order with their labels' do
      collected = plates.each_page.to_a

      expect(collected.map(&:first)).to eq((1..8).to_a)
      expect(collected.first).to eq([1, plates.print_page(1)])
      expect(collected.last.last.map(&:label)).to eq(['Plate 4'])
    end

    specify 'returns an enumerator without a block' do
      expect(offset_scan.each_page).to be_a(Enumerator)
    end
  end

  describe '#document_pages and #print_pages' do
    specify 'lists distinct document pages, integers first' do
      expect(sparse.document_pages).to eq([1, 5])
      expect(scattered.document_pages).to eq([1, 4, 5, 6, 7, 8, 9, 10])
    end

    specify 'lists distinct print pages, sorted' do
      expect(two_up.print_pages.map(&:label)).to eq(%w{300 301 302 303})
    end

    specify 'de-duplicates a page that spans several document pages' do
      expect(fold_out.print_pages.map(&:label)).to eq(['12'])
    end

    specify 'sorts integer labels before string labels' do
      expect(plates.print_pages.map(&:label))
        .to eq(['1', '2', '3', '4', 'Plate 1', 'Plate 2', 'Plate 3', 'Plate 4'])
    end
  end

  describe '#total_pages' do

    specify 'is nil for an empty map' do
      expect(map_class.new.total_pages).to be_nil
    end

    specify 'prefers a complete document side range' do
      expect(offset_scan.total_pages).to eq(20)
      expect(front_matter.total_pages).to eq(304)
    end

    specify 'uses a complete print run when the document side is not integers' do
      expect(remote.total_pages).to eq(3)
    end

    specify 'ignores a ragged print run and counts document pages' do
      ragged = map_class.unpack(
        [
          { 'document' => ['urn:a'], 'print' => ['10'] },
          { 'document' => ['urn:b'], 'print' => ['12'] }
        ]
      )

      expect(ragged.total_pages).to eq(2)
    end

    specify 'ignores a print run that is not all integers' do
      mixed = map_class.unpack(
        [
          { 'document' => ['urn:a'], 'print' => ['cover'] },
          { 'document' => ['urn:b'], 'print' => ['1'] }
        ]
      )

      expect(mixed.total_pages).to eq(2)
    end

    specify 'is the document page count for a sparse map' do
      expect(sparse.total_pages).to eq(2)
    end
  end

  describe '#mapped?' do
    specify 'is true when both sides cover the same count' do
      expect(offset_scan.mapped?).to be_truthy
      expect(front_matter.mapped?).to be_truthy
    end

    specify 'is false for a two-up scan' do
      expect(two_up.mapped?).to be_falsey
    end

    specify 'is false for a fold-out' do
      expect(fold_out.mapped?).to be_falsey
    end

    specify 'is false when a label repeats, because that is one printed page' do
      expect(duplicated_label.document_pages.size).to eq(6)
      expect(duplicated_label.print_pages.size).to eq(3)
      expect(duplicated_label.mapped?).to be_falsey
    end

    specify 'is false when empty' do
      expect(map_class.new.mapped?).to be_falsey
    end
  end

  describe '#gaps' do
    specify 'reports missing document pages and print numbers' do
      expect(sparse.gaps).to eq('document' => [2, 3, 4], 'print' => [301, 302, 303])
    end

    specify 'reports nothing for a complete map' do
      expect(offset_scan.gaps).to eq('document' => [], 'print' => [])
    end

    specify 'ignores string labels, which have no order to be missing from' do
      expect(front_matter.gaps['print']).to eq([])
      expect(plates.gaps['print']).to eq([])
    end
  end

  describe '#conflicts' do
    specify 'is empty when no document page is claimed twice' do
      expect(front_matter.conflicts).to eq([])
      expect(duplicated_label.conflicts).to eq([])
    end

    specify 'flags a document page claimed by two pairs' do
      map = map_class.unpack(
        [
          { 'document' => [{ 'from' => 1, 'to' => 3 }], 'print' => [{ 'from' => 1, 'to' => 3 }] },
          { 'document' => [3], 'print' => ['99'] }
        ]
      )

      expect(map.conflicts).to eq([3])
    end

    specify 'the later pair wins on the page they both claim' do
      map = map_class.unpack(
        [
          { 'document' => [{ 'from' => 1, 'to' => 3 }], 'print' => [{ 'from' => 1, 'to' => 3 }] },
          { 'document' => [3], 'print' => ['99'] }
        ]
      )

      expect(map.print_page(3).map(&:label)).to eq(['99'])
      expect(map.print_page(2).map(&:label)).to eq(['2'])
      expect(map.document_page('3')).to eq([])
    end

    specify 'a page carrying two labels says so within one pair, not across two' do
      map = map_class.unpack([{ 'document' => [1], 'print' => %w{300 301}, 'alignment' => 'collective' }])

      expect(map.print_page(1).map(&:label)).to eq(%w{300 301})
      expect(map.conflicts).to eq([])
    end
  end

  describe '#set' do

    specify 'assigns a print page to a document page' do
      map = offset_scan.set(1, '299')

      expect(map.print_page(1).map(&:label)).to eq(['299'])
      expect(map.document_page('299')).to eq([1])
    end

    specify 'replaces whatever the pairs assigned' do
      expect(offset_scan.set(1, '299').document_page('300')).to eq([])
    end

    specify 'accepts several labels' do
      expect(offset_scan.set(1, %w{299 300a}).print_page(1).map(&:label)).to eq(%w{299 300a})
    end

    specify 'appends rather than stacking a pair per call' do
      map = offset_scan.set(1, '299').set(1, '298')

      expect(map.pairs.size).to eq(2)
      expect(map.print_page(1).map(&:label)).to eq(['298'])
    end

    specify 'leaves a wider pair in place, still governing its other pages' do
      map = offset_scan.set(1, '299')

      expect(map.pairs.size).to eq(2)
      expect(map.print_page(2).map(&:label)).to eq(['301'])
      expect(map.print_page(20).map(&:label)).to eq(['319'])
    end

    specify 'drops an earlier pair it supersedes in full' do
      map = map_class.unpack([{ 'document' => [1], 'print' => ['300'] }]).set(1, '299')

      expect(map.pairs.size).to eq(1)
      expect(map.print_page(1).map(&:label)).to eq(['299'])
    end

    specify 'survives packing' do
      map = offset_scan.set(1, '299')

      expect(map.pack.size).to eq(2)
      expect(map_class.unpack(map.pack)).to eq(map)
      expect(map_class.unpack(map.pack).print_page(1).map(&:label)).to eq(['299'])
    end

    specify 'returns self' do
      expect(offset_scan.set(1, '299')).to be_a(map_class)
    end
  end

  describe '#shift' do

    specify 'shifts integer print pages' do
      shifted = offset_scan.shift(10)

      expect(shifted.print_page(1).map(&:label)).to eq(['310'])
      expect(shifted.document_page('310')).to eq([1])
    end

    specify 'leaves the document side alone' do
      expect(offset_scan.shift(10).document_pages).to eq(offset_scan.document_pages)
    end

    specify 'leaves roman labels untouched, since they are strings' do
      shifted = front_matter.shift(2)

      expect(shifted.print_page(1).map(&:label)).to eq(['i'])
      expect(shifted.print_page(5).map(&:label)).to eq(['3'])
    end

    specify 'leaves every other string label untouched' do
      shifted = map_class.unpack('1' => 'cover', '2' => '5').shift(1)

      expect(shifted.label_for(1)).to eq('cover')
      expect(shifted.label_for(2)).to eq('6')
    end

    specify 'does not mutate the receiver' do
      offset_scan.shift(10)
      expect(offset_scan.print_page(1).map(&:label)).to eq(['300'])
    end

    specify 'shifts the integer inside a template range' do
      expect(plates.shift(10).print_page(5).map(&:label)).to eq(['Plate 11'])
    end
  end

  describe '#page_tokens' do

    specify 'projects normalized labels' do
      expect(sparse.page_tokens).to eq(%w{300 304})
    end

    specify 'normalizes so a lookup cannot miss' do
      map = map_class.unpack('1' => '007', '2' => 'XI')

      expect(map.page_tokens).to include('7')
      expect(map.page_tokens).to include('xi')
    end

    specify 'is sorted and unique' do
      tokens = plates.page_tokens
      expect(tokens).to eq(tokens.uniq.sort)
    end

    specify 'covers every print page in the map' do
      all_fixtures.each do |map|
        map.print_pages.each { |page| expect(map.page_tokens).to include(page.normalized_label) }
      end
    end
  end

  describe '#== and #empty?' do
    specify 'compares the canonical packed form' do
      expect(map_class.unpack(offset_scan.pack)).to eq(offset_scan)
      expect(offset_scan).not_to eq(front_matter)
      expect(offset_scan).not_to eq('300')
    end

    specify 'reports emptiness' do
      expect(map_class.new.empty?).to be_truthy
      expect(offset_scan.empty?).to be_falsey
    end
  end

  describe '.from_iiif_manifest' do

    specify 'reads a v3 manifest' do
      map = map_class.from_iiif_manifest(
        'items' => [
          { 'id' => 'https://example.org/canvas/1', 'type' => 'Canvas',
            'label' => { 'en' => ['i'] } },
          { 'id' => 'https://example.org/canvas/2', 'type' => 'Canvas',
            'label' => { 'en' => ['ii'] } }
        ]
      )

      expect(map.document_pages.size).to eq(2)
      expect(map.document_page('ii')).to eq(['https://example.org/canvas/2'])
    end

    specify 'reads a v2 manifest' do
      map = map_class.from_iiif_manifest(
        'sequences' => [
          { 'canvases' => [{ '@id' => 'https://example.org/c/1', 'label' => '1' }] }
        ]
      )

      expect(map.label_for('https://example.org/c/1')).to eq('1')
    end

    specify 'leaves an unlabelled canvas unmapped' do
      map = map_class.from_iiif_manifest(
        'items' => [{ 'id' => 'https://example.org/canvas/1', 'type' => 'Canvas' }]
      )

      expect(map.print_page('https://example.org/canvas/1')).to eq([])
      expect(map.document_pages).to eq(['https://example.org/canvas/1'])
    end
  end

  describe '.from_bhl_item' do

    let(:item) {
      { 'Pages' => [
        { 'PageID' => 1001, 'PageNumbers' => [{ 'Number' => '10', 'Prefix' => 'Page' }] },
        { 'PageID' => 1002, 'PageNumbers' => [{ 'Number' => '11', 'Prefix' => 'Page' }] },
        { 'PageID' => 1003, 'PageNumbers' => [] }
      ] }
    }

    specify 'maps page identifiers to printed numbers' do
      map = map_class.from_bhl_item(item)

      expect(map.document_page('10')).to eq([1001])
      expect(map.print_page(1002).map(&:label)).to eq(['11'])
    end

    specify 'leaves a page with no printed number unmapped' do
      expect(map_class.from_bhl_item(item).print_page(1003)).to eq([])
    end

    specify 'accepts a resolver for the document page' do
      map = map_class.from_bhl_item(item, page_url: ->(id) { "https://www.biodiversitylibrary.org/page/#{id}" })

      expect(map.document_page('10')).to eq(['https://www.biodiversitylibrary.org/page/1001'])
    end

    specify 'packs and round-trips' do
      map = map_class.from_bhl_item(item)
      expect(map_class.unpack(map.pack)).to eq(map)
    end
  end

  describe 'scenario: an offset scan' do
    specify 'behaves end to end' do
      expect(offset_scan.total_pages).to eq(20)
      expect(offset_scan.mapped?).to be_truthy
      expect(offset_scan.document_page('305')).to eq([6])
      expect(offset_scan.label_for(6)).to eq('305')
      expect(offset_scan.gaps['document']).to eq([])
    end
  end

  describe 'scenario: roman front matter and an arabic body' do
    specify 'carries roman labels as strings' do
      expect(front_matter.print_page(1).map(&:label)).to eq(['i'])
      expect(front_matter.print_page(1).first.numeric_value).to be_nil
      expect(front_matter.print_page(5).first.numeric_value).to eq(1)
    end

    specify 'packs the front matter to a generated range, not twenty literals' do
      expect(front_matter.pack.first['print'])
        .to eq([{ 'from' => 'i', 'to' => 'iv', 'roman' => true }])
    end

    specify 'resolves both halves' do
      expect(front_matter.document_page('iii')).to eq([3])
      expect(front_matter.document_page('300')).to eq([304])
    end
  end

  describe 'scenario: a two-up scan' do
    specify 'one document page carries two printed pages' do
      expect(two_up.print_page(1).map(&:label)).to eq(%w{300 301})
      expect(two_up.document_page('301')).to eq([1])
      expect(two_up.mapped?).to be_falsey
      expect(two_up.total_pages).to eq(2)
    end
  end

  describe 'scenario: a plate section' do
    specify 'generates plate labels from a template' do
      expect(plates.print_page(5).map(&:label)).to eq(['Plate 1'])
      expect(plates.print_page(5).first.numeric_value).to be_nil
      expect(plates.document_page('Plate 3')).to eq([7])
    end

    specify 'does not collide with the body numbering' do
      expect(plates.document_page('1')).to eq([1])
      expect(plates.document_page('Plate 1')).to eq([5])
    end

    specify 'packs back to the template, not four literals' do
      expect(plates.pack.last['print'])
        .to eq([{ 'template' => 'Plate %d', 'from' => 1, 'to' => 4 }])
    end
  end

  describe 'scenario: a map keyed by remote page identifiers' do
    specify 'resolves URIs as document pages' do
      expect(remote.document_page('11')).to eq(['https://www.biodiversitylibrary.org/page/1002'])
      expect(remote.document_pages.size).to eq(3)
      expect(remote.total_pages).to eq(3)
    end

    specify 'has no document side gaps to report' do
      expect(remote.gaps['document']).to eq([])
    end
  end

  describe 'scenario: a sparse map' do
    specify 'reports what is missing without inventing it' do
      expect(sparse.document_pages).to eq([1, 5])
      expect(sparse.document_page('302')).to eq([])
      expect(sparse.gaps['document']).to eq([2, 3, 4])
    end
  end

  describe 'scenario: a fold-out' do
    specify 'one printed page across contiguous document pages' do
      expect(fold_out.document_page('12')).to eq([40, 41, 42])
      expect(fold_out.print_page(41).map(&:label)).to eq(['12'])
      expect(fold_out.print_pages.size).to eq(1)
    end
  end

  describe 'scenario: a scattered printed page' do
    specify 'survives the round trip while resolving in full' do
      expect(scattered.document_page('4')).to eq([1, 4, 5, 6, 7, 8, 9, 10])
      expect(map_class.unpack(scattered.pack)).to eq(scattered)
      expect(scattered.pack.first['document']).to eq([1, { 'from' => 4, 'to' => 10 }])
    end

    specify 'every document page in the set reports the same printed page' do
      scattered.document_pages.each do |dp|
        expect(scattered.print_page(dp).map(&:label)).to eq(['4'])
      end
    end
  end
end
