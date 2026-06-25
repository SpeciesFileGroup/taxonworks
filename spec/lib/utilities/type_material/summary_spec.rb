require 'rails_helper'

describe Utilities::TypeMaterial::Summary do

  let(:date_counts) do
    [
      [Date.new(1900, 1, 1), 2],
      [Date.new(1905, 1, 1), 0],
      [nil, 1],
      [Date.new(1923, 1, 1), 3]
    ]
  end

  context '.coverage_totals' do
    specify 'counts names with at least one TypeMaterial' do
      expect(described_class.coverage_totals(date_counts)).to eq(with: 3, without: 1, total: 4)
    end
  end

  context '.decade_windows' do
    let(:result) { described_class.decade_windows(date_counts) }

    specify 'reports names without a year separately' do
      expect(result[:without_year]).to eq(1)
    end

    specify 'spans contiguous decades from min to max' do
      expect(result[:windows].map { |w| w[:decade] }).to eq([1900, 1910, 1920])
    end

    specify 'splits each decade by with/without TypeMaterial' do
      expect(result[:windows]).to include(
        { decade: 1900, with: 1, without: 1 },
        { decade: 1910, with: 0, without: 0 },
        { decade: 1920, with: 1, without: 0 }
      )
    end

    specify 'empty input yields no windows' do
      expect(described_class.decade_windows([])).to eq(windows: [], without_year: 0)
    end
  end

  context '.counts' do
    specify 'counts values descending' do
      expect(described_class.counts(%w[a b a c a b])).to eq('a' => 3, 'b' => 2, 'c' => 1)
    end
  end

  context '.stacked' do
    let(:entries) do
      [
        ['NHMUK', 'holotype', 2],
        ['NHMUK', 'paratype', 1],
        ['Unspecified', 'holotype', 5]
      ]
    end

    let(:result) { described_class.stacked(entries, stacks: %w[holotype paratype]) }

    specify 'orders categories by total descending with Unspecified last' do
      expect(result[:categories]).to eq(['NHMUK', 'Unspecified'])
    end

    specify 'builds one aligned series per stack key' do
      expect(result[:series]).to eq(
        [
          { type_type: 'holotype', data: [2, 5] },
          { type_type: 'paratype', data: [1, 0] }
        ]
      )
    end
  end
end
