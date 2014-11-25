require 'rails_helper'

describe 'Geo' do

  context 'bad values' do

    specify 'limit check w/letter' do
      expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('92:5:18.1N')).to eq('92:5:18.1: Out of range (92.08836111111111)')
    end

    specify 'limit check wo/letter' do
      expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('192:5:18.1')).to eq('192:5:18.1: Out of range (192.0883611111111)')
    end
  end

  context 'a Northern latitude' do
    # let(:lat_n) { '42:5:18.1N' }

    specify 'with uppercase letter' do
      # pending 'completion of method to convert DMS to DD'
      expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42:5:18.1N')).to eq('42.08836111111111')
    end

    specify 'with lowercase letter' do
      # pending 'completion of method to convert DMS to DD'
      expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42:5:18.1n')).to eq('42.08836111111111')
    end

    specify 'with no letter' do
      # pending 'completion of method to convert DMS to DD'
      expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42:5:18.1')).to eq('42.08836111111111')
    end
  end

  context 'a Southern latitude' do
    # let(:lat_n) { '42:5:18.1S' }

    specify 'with uppercase letter' do
      # pending 'completion of method to convert DMS to DD'
      expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42:5:18.1S')).to eq('-42.08836111111111')
    end

    specify 'with no letter' do
      # pending 'completion of method to convert DMS to DD'
      expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('-42:5:18.1')).to eq('-42.08836111111111')
    end
  end

  context 'a Western longitude' do
    let(:lng_w) { '88:11:43.3W' }

    specify 'with letter' do
      # pending 'completion of method to convert DMS to DD'
      expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(lng_w)).to eq('-88.19536111111111')
    end
  end

end
