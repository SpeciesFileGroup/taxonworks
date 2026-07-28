require 'rails_helper'

describe Utilities::Roman do

  let(:roman) { Utilities::Roman }

  describe '.roman?' do

    specify 'recognizes canonical numerals' do
      expect(roman.roman?('i')).to be_truthy
      expect(roman.roman?('xiv')).to be_truthy
      expect(roman.roman?('mcmlxxxiv')).to be_truthy
      expect(roman.roman?('mmmmcmxcix')).to be_truthy
    end

    specify 'ignores case' do
      expect(roman.roman?('XIV')).to be_truthy
      expect(roman.roman?('XiV')).to be_truthy
    end

    specify 'ignores surrounding whitespace' do
      expect(roman.roman?('  xiv ')).to be_truthy
    end

    specify 'rejects non-canonical forms' do
      expect(roman.roman?('iiii')).to be_falsey
      expect(roman.roman?('vv')).to be_falsey
      expect(roman.roman?('ic')).to be_falsey
    end

    specify 'rejects words that use only roman letters' do
      expect(roman.roman?('mixed')).to be_falsey
      expect(roman.roman?('did')).to be_falsey
    end

    specify 'accepts a word that happens to be a numeral' do
      expect(roman.roman?('mix')).to be_truthy
      expect(roman.to_i('mix')).to eq(1009)
    end

    specify 'rejects the empty string and whitespace' do
      expect(roman.roman?('')).to be_falsey
      expect(roman.roman?('   ')).to be_falsey
    end

    specify 'rejects anything that is not a string' do
      expect(roman.roman?(12)).to be_falsey
      expect(roman.roman?(nil)).to be_falsey
      expect(roman.roman?(:xiv)).to be_falsey
    end
  end

  describe '.to_i' do

    specify 'converts' do
      expect(roman.to_i('i')).to eq(1)
      expect(roman.to_i('iv')).to eq(4)
      expect(roman.to_i('xiv')).to eq(14)
      expect(roman.to_i('mcmlxxxiv')).to eq(1984)
    end

    specify 'ignores case and whitespace' do
      expect(roman.to_i('XIV')).to eq(14)
      expect(roman.to_i(' xiv ')).to eq(14)
    end

    specify 'raises on anything else' do
      expect { roman.to_i('nope') }.to raise_error(ArgumentError)
      expect { roman.to_i('iiii') }.to raise_error(ArgumentError)
      expect { roman.to_i('') }.to raise_error(ArgumentError)
      expect { roman.to_i(nil) }.to raise_error(ArgumentError)
    end
  end

  describe '.to_i_or_nil' do

    specify 'converts what it can' do
      expect(roman.to_i_or_nil('xiv')).to eq(14)
    end

    specify 'returns nil rather than raising' do
      expect(roman.to_i_or_nil('nope')).to be_nil
      expect(roman.to_i_or_nil(nil)).to be_nil
      expect(roman.to_i_or_nil(12)).to be_nil
    end
  end

  describe '.from_i' do

    specify 'converts' do
      expect(roman.from_i(1)).to eq('i')
      expect(roman.from_i(4)).to eq('iv')
      expect(roman.from_i(14)).to eq('xiv')
      expect(roman.from_i(1984)).to eq('mcmlxxxiv')
    end

    specify 'is lower case by default' do
      expect(roman.from_i(14)).to eq('xiv')
    end

    specify 'upcases on request' do
      expect(roman.from_i(14, upcase: true)).to eq('XIV')
    end

    specify 'raises outside the domain' do
      expect { roman.from_i(0) }.to raise_error(ArgumentError)
      expect { roman.from_i(-1) }.to raise_error(ArgumentError)
      expect { roman.from_i(5000) }.to raise_error(ArgumentError)
    end

    specify 'raises on anything that is not an integer' do
      expect { roman.from_i('14') }.to raise_error(ArgumentError)
      expect { roman.from_i(nil) }.to raise_error(ArgumentError)
      expect { roman.from_i(1.5) }.to raise_error(ArgumentError)
    end

    specify 'reaches the ends of the domain' do
      expect(roman.from_i(Utilities::Roman::MINIMUM)).to eq('i')
      expect(roman.from_i(Utilities::Roman::MAXIMUM)).to eq('mmmmcmxcix')
    end
  end

  describe 'round trip' do

    specify 'holds across the whole domain' do
      Utilities::Roman::DOMAIN.each do |i|
        expect(roman.to_i(roman.from_i(i))).to eq(i)
      end
    end

    specify 'everything it generates it also recognizes' do
      Utilities::Roman::DOMAIN.each do |i|
        expect(roman.roman?(roman.from_i(i))).to be_truthy
      end
    end

    specify 'holds for the upper case form too' do
      [1, 4, 14, 40, 90, 400, 900, 1984, 4999].each do |i|
        expect(roman.to_i(roman.from_i(i, upcase: true))).to eq(i)
      end
    end
  end
end
