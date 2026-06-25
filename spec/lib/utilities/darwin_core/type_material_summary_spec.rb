require 'rails_helper'

describe Utilities::DarwinCore::TypeMaterialSummary do

  let(:rows) do
    [
      { 'sex' => 'male',   'country' => 'USA',    'decimalLatitude' => '10.0', 'decimalLongitude' => '20.0' },
      { 'sex' => 'female', 'country' => 'USA',    'decimalLatitude' => nil,    'decimalLongitude' => nil },
      { 'sex' => 'male',   'country' => 'Canada', 'decimalLatitude' => '5.0',  'decimalLongitude' => '' },
      { 'sex' => '',       'country' => nil,      'decimalLatitude' => '1.0',  'decimalLongitude' => '2.0' }
    ]
  end

  context '.sex_counts' do
    specify 'counts records by sex, blanks to Unspecified' do
      expect(described_class.sex_counts(rows)).to eq('male' => 2, 'female' => 1, 'Unspecified' => 1)
    end

    specify 'orders descending by count' do
      expect(described_class.sex_counts(rows).keys.first).to eq('male')
    end
  end

  context '.country_counts' do
    specify 'counts records by country, blanks to Unspecified' do
      expect(described_class.country_counts(rows)).to eq('USA' => 2, 'Canada' => 1, 'Unspecified' => 1)
    end
  end

  context '.georeference_partition' do
    specify 'requires both coordinates to be present' do
      expect(described_class.georeference_partition(rows)).to eq(
        georeferenced: 2,
        not_georeferenced: 2,
        total: 4
      )
    end
  end

  context '.georeferenced?' do
    specify 'true only when both coordinates present' do
      expect(described_class.georeferenced?(rows[0])).to be true
      expect(described_class.georeferenced?(rows[2])).to be false
    end
  end
end
