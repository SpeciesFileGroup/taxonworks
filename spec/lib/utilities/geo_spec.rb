require 'rails_helper'

describe 'Geo' do

  context 'bad values' do

    specify 'limit check w/letter' do
      expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('92:5:18.1N')).to be_nil
    end

    specify 'limit check wo/letter' do
      expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('192:5:18.1')).to be_nil
    end
  end

  context 'NN:NN:NNA or ANN:NN:NN' do

    context 'a Northern latitude' do

      specify 'with uppercase letter front' do
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('N42:5:18.1')).to eq('42.088361')
      end

      specify 'with uppercase letter back' do
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42:5:18.1N')).to eq('42.088361')
      end

      specify 'with lowercase letter' do
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42:5:18.1n')).to eq('42.088361')
      end

      specify 'with no letter' do
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42:5:18.1')).to eq('42.088361')
      end

      specify 'only degrees and decimal minutes' do
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42:30.1')).to eq('42.501667')
      end
    end

    context 'a Southern latitude' do

      specify 'with uppercase letter' do
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42:5:18.1S')).to eq('-42.088361')
      end

      specify 'with no letter' do
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('-42:5:18.1')).to eq('-42.088361')
      end
    end

    context 'a Western longitude' do

      specify 'with letter' do
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('88:11:43.3W')).to eq('-88.195361')
      end
    end

    specify 'without letter' do
      expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('-88:11:43.3')).to eq('-88.195361')
    end


    context 'an Eastern longitude' do

      specify 'with letter' do
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('88:11:43.3E')).to eq('88.195361')
      end

      specify 'without letter' do
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('88:11:43.3')).to eq('88.195361')
      end
    end
  end

  context 'NNºNN\'NN"A or ANNºNN\'NN"' do

    context 'a Northern latitude' do

      specify 'with uppercase letter front' do
        # pending 'fixing for degree symbol, tick and doubletick'
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('N42º5\'18.1"')).to eq('42.088361')
      end

      specify 'with uppercase letter back' do
        # pending 'fixing for degree symbol, tick and doubletick'
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42º5\'18.1"N')).to eq('42.088361')
      end

      specify 'with no letter' do
        # pending 'fixing for degree symbol, tick and doubletick'
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42º5\'18.1"')).to eq('42.088361')
      end
    end

    context 'a Southern latitude' do

      specify 'with uppercase letter' do
        # pending 'fixing for degree symbol, tick and doubletick'
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('S42º5\'18.1"')).to eq('-42.088361')
      end

      specify 'with no letter' do
        # pending 'fixing for degree symbol, tick and doubletick'
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('-42º5\'18.1"')).to eq('-42.088361')
      end
    end
  end

  context 'NN.NNNA or ANN.NNN' do

    context 'a Northern latitude' do

      specify 'with uppercase letter front' do
        # pending 'fixing for degree symbol, tick and doubletick'
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('N42.1234567')).to eq('42.123457')
      end

      specify 'with no letter' do
        # pending 'fixing for degree symbol, tick and doubletick'
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42.1234567')).to eq('42.123457')
      end
    end

    context 'a Southern latitude' do

      specify 'with lowercase letter' do
        # pending 'fixing for degree symbol, tick and doubletick'
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('s42.1234567')).to eq('-42.123457')
      end

      specify 'with no letter' do
        # pending 'fixing for degree symbol, tick and doubletick'
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('-42.1234567')).to eq('-42.123457')
      end
    end
  end

  context 'multiple use cases' do

    LATLONG_USE_CASES.each { |co_ordinate, result|
      specify "case #{co_ordinate}" do
        pending 'full construction of the use_case hash'
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(co_ordinate)).to eq(result)
      end
    }
  end
end
