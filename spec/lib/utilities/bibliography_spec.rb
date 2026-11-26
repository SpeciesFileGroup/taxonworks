require 'rails_helper'

describe Utilities::Bibliography do
  let(:b) { Utilities::Bibliography }

  context 'YEAR_SUFFIX, as stored' do
    %w{a B ab AA}.each do |suffix|
      specify suffix do
        expect(suffix).to match(/\A#{b::YEAR_SUFFIX}\z/)
      end
    end
  end

  context 'YEAR_WITH_SUFFIX, in running text' do
    {
      'Smith 1936a. Title' => ['1936', 'a'],
      'Smith 1936A. Title' => ['1936', 'A'],
      'Smith 1936ab. Title' => ['1936', 'ab'],
      'Smith (1936 b) Title' => ['1936', 'b'],
      'Smith 2001, Title' => ['2001', nil],
      'Smith 1990 A new species' => ['1990', nil],
      'Smith 1990 Annales' => ['1990', nil],
      'Smith 1990 bc' => ['1990', nil],
      'Smith 1499' => nil,
      'Smith 2100' => nil,
      'Smith 12001' => nil
    }.each do |text, captures|
      specify text do
        m = text.match(b::YEAR_WITH_SUFFIX)
        expect(m && [m[1], m[2]&.strip]).to eq(captures)
      end
    end
  end

  context '.volume_number' do
    {
      '96' => '96',
      '96(2)' => '96',
      ' 96 (2)' => '96',
      '10(2):149-158' => '10',
      'Vol. 10' => '10',
      'Volume 10 (2)' => '10',
      '36A' => '36A',
      '' => nil,
      nil => nil
    }.each do |value, number|
      specify value.inspect do
        expect(b.volume_number(value)).to eq(number)
      end
    end
  end

  context '.first_page' do
    {
      '149-158' => '149',
      'p. 5' => '5',
      'xii + 248 pp.' => '248',
      'i-iv' => nil,
      nil => nil
    }.each do |value, page|
      specify value.inspect do
        expect(b.first_page(value)).to eq(page)
      end
    end
  end

  specify 'VOLUME_PAGES_PATTERNS capture volume, then first page' do
    m = b::VOLUME_PAGES_PATTERNS.lazy.filter_map { |p| 'Journal, 58(3), 529–536.'.match(p) }.first
    expect(m.captures).to eq(['58', '529'])
  end
end
