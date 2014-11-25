require 'rails_helper'

describe 'Geo' do

  context 'a Northern latitude' do
    let(:lat_n) {'42:5:18.1N'}

    specify 'with letter' do
      pending 'completion of method to convert DMS to DD'
      expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(lat_n)).to eq('42.123456789')
    end
  end

  context 'a Western longitude' do
    let(:lng_w) {'88:11:43.3W'}

    specify 'with letter' do
      pending 'completion of method to convert DMS to DD'
      expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(lng_w)).to eq('-88.123456789')
    end
  end

end
