require 'rails_helper'

# TODO: Extract all this to a gem
describe 'Geo', group: :geo do

  context 'degrees_minutes_seconds_to_decimal_degrees' do

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

      use_cases = {'-88.241121º'                   => '-88.241121', #current test case ['-88.241121°']
                   'W88.241121º'                   => '-88.241121', #current test case ['-88.241121°']
                   'w88∫11′43.4″'                  => '-88.195389',
                   '40º26\'46"N'                   => '40.446111', # using MAC-native symbols
                   '079º58\'56"W'                  => '-79.982222', # using MAC-native symbols
                   '40:26:46.302N'                 => '40.446195',
                   '079:58:55.903W'                => '-79.982195',
                   '40°26′46″N'                    => '40.446111',
                   '079°58′56″W'                   => '-79.982222',
                   '40d 26′ 46″ N'                 => '40.446111',
                   '079d 58′ 56″ W'                => '-79.982222',
                   '40.446195N'                    => '40.446195',
                   '79.982195W'                    => '-79.982195',
                   '40.446195'                     => '40.446195',
                   '-79.982195'                    => '-79.982195',
                   '40° 26.7717'                   => '40.446195',
                   '-79° 58.93172'                 => '-79.982195',
                   'N40:26:46.302'                 => '40.446195',
                   'W079:58:55.903'                => '-79.982195',
                   'N40°26′46″'                    => '40.446111',
                   'W079°58′56″'                   => '-79.982222',
                   'N40d 26′ 46″'                  => '40.446111',
                   'W079d 58′ 56″'                 => '-79.982222',
                   'N40.446195'                    => '40.446195',
                   'W79.982195'                    => '-79.982195',
                   # some special characters for Dmitry
                   "  40\u02da26¥46¥S"             => '-40.446111',
                   '42∞5\'18.1"S'                  => '-42.088361',
                   'w88∞11\'43.3"'                 => '-88.195361',
                   "  42\u02da5¥18.1¥S"            => '-42.088361',
                   "  42º5'18.1'S"                 => '-42.088361',
                   "  42o5\u02b918.1\u02b9\u02b9S" => '-42.088361',
                   'w88∫11′43.3″'                  => '-88.195361',
                   # weird things that might break the converter...
                   -10                             => '-10.0',
                   '-11'                           => '-11.0',
                   'bad_data-10'                   => nil,
                   'bad_data-10.1'                 => nil,
                   'nan'                           => nil,
                   'NAN'                           => nil}

      # Dmitry's special cases of º, ', "

      # case 1:  ]  42∞5'18.1"S[
      # "\D(\d+) ?[\*∞∫o\u02DA ] ?(\d+) ?[ '¥\u02B9\u02BC\u02CA] ?(\d+[\.|,]\d+|\d+) ?[ ""\u02BA\u02EE'¥\u02B9\u02BC\u02CA]['¥\u02B9\u02BC\u02CA]? ?([nN]|[sS])"

      #  1. Non-digit => dropped
      #  2. 1 or more digits
      #     => group 0
      #  3. 0 or 1 spaces => dropped
      #  4. *, ∞, ∫, o, \u02DA, space
      #     => match for º
      #  5. 0 or 1 spaces => dropped
      #  6. 1 or more digits
      #     => group 1
      #  7. 0 or 1 spaces => dropped
      #  8. space, ', ¥, \u02B9, \u02BC, \u02CA
      #     => match for '
      #  9. 0 or 1 spaces => dropped
      # 10.
      #     a.
      #       1. 1 or more digits
      #       2. period, |, comma, => match for period
      #       3. 1 or more digits
      #     or
      #     b. 1 or more digits
      #      => group 2
      # 11. 0 or 1 spaces => dropped
      # 12. space, ", \u02BA, \u02EE, ', ¥, \u02B9, \u02BC, \u02CA, followed by 0 or 1 of ', ¥, \u02B9, \u02BC, \u02CA
      #     => match for "
      # 13. 0 or 1 spaces => dropped
      # 14. N, S, E, W, case-insensitive cardinal letter
      #     => group 3

      # case 2: ] S42∞5'18.1"[
      # "\W([nN]|[sS])\.? ?(\d+) ?[\*∞∫o\u02DA ] ?(\d+) ?[ '¥\u02B9\u02BC\u02CA] ?(\d+[\.|,]\d+|\d+) ?[ ""\u02BA\u02EE'¥\u02B9\u02BC\u02CA]['¥\u02B9\u02BC\u02CA]?[\.,;]?"

      # case 3: ] S42∞5.18'[
      # "\W([nN]|[sS])\.? ?(\d+) ?[\*∞∫o\u02DA ] ?(\d+[\.|,]\d+|\d+) ?[ '¥\u02B9\u02BC\u02CA][\.,;]?"

      # case 4: ]42∞5.18'S[
      # "\D(\d+) ?[\*∞∫o\u02DA ] ?(\d+[\.|,]\d+|\d+) ?[ '¥\u02B9\u02BC\u02CA]? ?([nN]|[sS])"
      # case 5: ]S42.18∞[
      # "\W([nN]|[sS])\.? ?(\d+[\.|,]\d+|\d+) ?[\*∞∫∫o\u02DA ][\.,;]?"

      # case 6: ]42.18∞S[
      # "\D(\d+[\.|,]\d+|\d+) ?[\*∞∫o\u02DA ] ?([nN]|[sS])"

      # case 7: ]-12.263[
      # "\D\[(-?\d+[\.|,]\d+|\-?d+)"

      @entry    = 0

      use_cases.each { |co_ordinate, result|
        @entry += 1
        specify "case #{@entry}: #{co_ordinate} should yield #{result}" do
          # pending 'full construction of the use_case hash'
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(co_ordinate)).to eq(result)
        end
      }
    end
  end

  context 'elevation_in_meters' do
    context 'multiple use cases' do
      use_cases = {' 12345'                => 12345.0,
                   ' 123.45'               => 123.45,
                   ' 123 ft'               => 37.4904,
                   ' 123 ft.'              => 37.4904,
                   ' 123 feet'             => 37.4904,
                   ' 1 foot'               => 0.3048,
                   ' 123 f'                => 37.4904,
                   '   123 f.'             => 37.4904,
                   ' 123 m'                => 123.0,
                   '  123 meters'          => 123.0,
                   '     123 m.'           => 123.0,
                   '    123 km'            => 123000.0,
                   ' 123 km.'              => 123000.0,
                   '       123 kilometers' => 123000.0,
                   '123 kilometer'         => 123000.0,
                   ''                      => 0.0,
                   'sillyness'             => 0.0}

      @entry = 0

      use_cases.each { |elevation, result|
        @entry += 1
        specify "case #{@entry}: #{elevation} should yield #{result}" do
          expect(Utilities::Geo.elevation_in_meters(elevation)).to eq(result)
        end
      }
    end
  end
end
