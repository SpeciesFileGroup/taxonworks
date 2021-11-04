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

    # rubocop:disable Style/StringHashKeys
    context 'single use case for lat/long hunt_wrapper' do
      use_case = {'  N 23.23  W 44.44  ' => {'DD1A' => {method: 'text, DD1A'},
                                             'DD1B' => {piece:  'N 23.23  W 44.44',
                                                        lat:    'N 23.23',
                                                        long:   'W 44.44',
                                                        method: 'text, DD1B'},
                                             'DD2'  => {method: 'text, DD2'},
                                             'DM1'  => {method: 'text, DM1'},
                                             'DMS2' => {method: 'text, DMS2'},
                                             'DM3'  => {method: 'text, DM3'},
                                             'DMS4' => {method: 'text, DMS4'},
                                             'DD5'  => {piece:  'N 23.23  W 44.44  ',
                                                        lat:    'N 23.23  ',
                                                        long:   'W 44.44  ',
                                                        method: 'text, DD5'},
                                             'DD6'  => {method: 'text, DD6'},
                                             'DD7'  => {method: 'text, DD7'},
                                             '(;)'  => {method: '(;)'},
                                             '(,)'  => {method: '(,)'},
                                             '( )'  => {method: '( )'}}
      }
      @entry   = 0

      use_case.each { |label, result|
        @entry += 1
        specify "case #{@entry}: '#{label}' should yield #{result}" do
          this_case = Utilities::Geo.hunt_wrapper(label)
          expect(this_case).to eq(result)
        end
      }
    end

    context 'multiple use cases for lat/long hunt_wrapper' do
      use_cases = {
        'Here is some extra text: N 23.23  W 44.44  More stuff at the end' =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {piece:  'N 23.23  W 44.44',
                      lat:    'N 23.23',
                      long:   'W 44.44',
                      method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {piece:  'N 23.23  W 44.44  ',
                      lat:    'N 23.23  ',
                      long:   'W 44.44  ',
                      method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {method: '(,)'},
           '( )'  => {method: '( )'}},
        'Here is some extra text:,;    23.23 N  44.44 W,; More stuff at the end'                                                                          =>
          {'DD1A' => {piece:  '23.23 N  44.44 W',
                      lat:    '23.23 N',
                      long:   '44.44 W',
                      method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {piece:  '23.23 N  44.44 W',
                      lat:    '23.23 N',
                      long:   '44.44 W',
                      method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {piece:  '23.23 N  44.44 W',
                      lat:    '23.23 N',
                      long:   '44.44 W',
                      method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece:  '23.23 N  44.44 W',
                      lat:    '23.23 N',
                      long:   '44.44 W',
                      method: '(;)'},
           '(,)'  => {piece:  '23.23 N  44.44 W',
                      lat:    '23.23 N',
                      long:   '44.44 W',
                      method: '(,)'},
           '( )'  => {method: '( )'}},
        "c_e_485: ARGENTINA: Jujuy, rt 9, km 1706, Finca Yala, 1500m, 24o7'2\"S65o24'13\"W, 16 Jan 2008 C.H.Dietrich, Hg vapor lights, AR13-1"            =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {piece:  "24o7'2\"S65o24'13\"W",
                      lat:    "24o7'2\"S",
                      long:   "65o24'13\"W",
                      method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {piece:  " 24o7'2\"S65o24'13\"W",
                      lat:    " 24o7'2\"S65o24'13\"W",
                      method: '(,)'},
           '( )'  => {piece:  "24o7'2\"S65o24'13\"W,",
                      lat:    "24o7'2\"S65o24'13\"W,",
                      method: '( )'}},
        'c_e_171 prairie # 1 N 41.87734 W 89.34677 2 VIII'                                                                                                =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {piece:  'N 41.87734 W 89.34677',
                      lat:    'N 41.87734',
                      long:   'W 89.34677',
                      method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {piece:  'N 41.87734 W 89.34677 ',
                      lat:    'N 41.87734 ',
                      long:   'W 89.34677 ',
                      method: 'text, DD5'},
           'DD6'  => {piece:  '1 N 41.87734 W',
                      lat:    '1 N',
                      long:   '41.87734 W',
                      method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {method: '(,)'},
           '( )'  => {method: '( )'}},
        " 42°5'18.1\"S 88°11'43.3\"W"                                                                                                                     =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4',
                      piece:  "42°5'18.1\"S 88°11'43.3\"W",
                      lat:    "42°5'18.1\"S",
                      long:   "88°11'43.3\"W"},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece:  " 42°5'18.1\"S 88°11'43.3\"W",
                      lat:    " 42°5'18.1\"S 88°11'43.3\"W",
                      method: '(;)'},
           '(,)'  => {piece:  " 42°5'18.1\"S 88°11'43.3\"W",
                      lat:    " 42°5'18.1\"S 88°11'43.3\"W",
                      method: '(,)'},
           '( )'  => {piece:  "42°5'18.1\"S 88°11'43.3\"W",
                      lat:    "42°5'18.1\"S",
                      long:   "88°11'43.3\"W",
                      method: '( )'}
          },
        "  S42°5'18.1\" W88o11'43.3\""                                                                                                                    =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {piece:  "S42°5'18.1\" W88o11'43.3\"",
                      lat:    "S42°5'18.1\"",
                      long:   "W88o11'43.3\"",
                      method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece:  "  S42°5'18.1\" W88o11'43.3\"",
                      lat:    "  S42°5'18.1\" W88o11'43.3\"",
                      method: '(;)'},
           '(,)'  => {piece:  "  S42°5'18.1\" W88o11'43.3\"",
                      lat:    "  S42°5'18.1\" W88o11'43.3\"",
                      method: '(,)'},
           '( )'  => {piece:  "S42°5'18.1\" W88o11'43.3\"",
                      lat:    "S42°5'18.1\"",
                      long:   "W88o11'43.3\"",
                      method: '( )'}
          },
        "  S42o5.18' W88°11,43'"                                                                                                                          =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {piece:  "S42o5.18' W88°11,43'",
                      lat:    "S42o5.18'",
                      long:   "W88°11,43'",
                      method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece:  "  S42o5.18' W88°11,43'",
                      lat:    "  S42o5.18' W88°11,43'",
                      method: '(;)'},
           '(,)'  => {piece:  "  S42o5.18' W88°11,43'",
                      lat:    "  S42o5.18' W88°11",
                      long:   "43'",
                      method: '(,)'},
           '( )'  => {piece:  "S42o5.18' W88°11,43'",
                      lat:    "S42o5.18'",
                      long:   "W88°11,43'",
                      method: '( )'}
          },
        "42°5.18'S 88°11.43'W"                                                                                                                            =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {piece:  "42°5.18'S 88°11.43'W",
                      lat:    "42°5.18'S",
                      long:   "88°11.43'W",
                      method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece:  "42°5.18'S 88°11.43'W",
                      lat:    "42°5.18'S 88°11.43'W",
                      method: '(;)'},
           '(,)'  => {piece:  "42°5.18'S 88°11.43'W",
                      lat:    "42°5.18'S 88°11.43'W",
                      method: '(,)'},
           '( )'  => {piece:  "42°5.18'S 88°11.43'W",
                      lat:    "42°5.18'S",
                      long:   "88°11.43'W",
                      method: '( )'}},
        'S42.18° W88.34°'                                                                                                                                 =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {piece:  'S42.18° W88.34°',
                      lat:    'S42.18°',
                      long:   'W88.34°',
                      method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece:  'S42.18° W88.34°',
                      lat:    'S42.18° W88.34°',
                      method: '(;)'},
           '(,)'  => {piece:  'S42.18° W88.34°',
                      lat:    'S42.18° W88.34°',
                      method: '(,)'},
           '( )'  => {piece:  'S42.18° W88.34°',
                      lat:    'S42.18°',
                      long:   'W88.34°',
                      method: '( )'}
          },
        '42.18°S 88.43°W'                                                                                                                                 =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {piece:  '42.18°S 88.43°W',
                      lat:    '42.18°S',
                      long:   '88.43°W',
                      method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece:  '42.18°S 88.43°W',
                      lat:    '42.18°S 88.43°W',
                      method: '(;)'},
           '(,)'  => {piece:  '42.18°S 88.43°W',
                      lat:    '42.18°S 88.43°W',
                      method: '(,)'},
           '( )'  => {piece:  '42.18°S 88.43°W',
                      lat:    '42.18°S',
                      long:   '88.43°W',
                      method: '( )'}
          },
        '[-12.263, 49.398]'                                                                                                                               =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {piece:  '[-12.263, 49.398]',
                      lat:    '-12.263',
                      long:   '49.398',
                      method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {method: '(,)'},
           '( )'  => {method: '( )'}
          },
        '[12.263, -49.398]'                                                                                                                               =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {piece:  '[12.263, -49.398]',
                      lat:    '12.263',
                      long:   '-49.398',
                      method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {method: '(,)'},
           '( )'  => {method: '( )'}
          },
        "DDA03-001 (1) U.S.A. IL, Cook Co., Calumet, Powder Horn Lake East forest, vacuuming N41o38.395' W87o31.72' 23 V 2003 (C. Dietrich, D. Dmitriev)" =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {piece:  "N41o38.395' W87o31.72'",
                      lat:    "N41o38.395'",
                      long:   "W87o31.72'",
                      method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {method: '(,)'},
           '( )'  => {piece:  "N41o38.395' W87o31.72'",
                      lat:    "N41o38.395'",
                      long:   "W87o31.72'",
                      method: '( )'}
          },
        "#32, USA, California, Guatay, 35 mi E San Diego, N 32o35'45\" W 116o32'27\" 5 V 2003 D. Dmitriev"                                                =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {piece:  "N 32o35'45\" W 116o32'27\"",
                      lat:    "N 32o35'45\"",
                      long:   "W 116o32'27\"",
                      method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {piece:  " 35 mi E San Diego, N 32o35'45\" W 116o32'27\" 5 V 2003 D. Dmitriev",
                      lat:    ' 35 mi E San Diego',
                      long:   " N 32o35'45\" W 116o32'27\" 5 V 2003 D. Dmitriev",
                      method: '(,)'},
           '( )'  => {piece:  "32o35'45\" 116o32'27\"",
                      lat:    "32o35'45\"",
                      long:   "116o32'27\"",
                      method: '( )'}
          },
        'Hancock Agricultural; Res. Station,, Hancock; Waushara County, WI; 43.836 N 89.258 W'                                                            =>
          {'DD1A' => {piece:  '43.836 N 89.258 W',
                      lat:    '43.836 N',
                      long:   '89.258 W',
                      method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {piece:  '43.836 N 89.258 W',
                      lat:    '43.836 N',
                      long:   '89.258 W',
                      method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {piece:  '43.836 N 89.258 W',
                      lat:    '43.836 N',
                      long:   '89.258 W',
                      method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece:  '43.836 N 89.258 W',
                      lat:    '43.836 N',
                      long:   '89.258 W',
                      method: '(;)'},
           '(,)'  => {piece:  '43.836 N 89.258 W',
                      lat:    '43.836 N',
                      long:   '89.258 W',
                      method: '(,)'},
           '( )'  => {method: '( )'}
          },
        'KREIS ILLUKSTE; ♀ GEMEINDE PRODE; MANELI. 23.V 1923; LATVIA. O.CONDE'                                                                            =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {method: '(,)'},
           '( )'  => {method: '( )'}
          },
        "Kazakhstan 14.VI.2001; 100 km N. Taldy-Kurgan; Dunes around Mataj; 45 54'N, 78 43'E; M. Hauser"                                                  =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {piece:  "45 54'N, 78 43'E",
                      lat:    "45 54'N",
                      long:   "78 43'E",
                      method: 'text, DD2'},
           'DM1'  => {piece:  "45 54'N, 78 43'E",
                      lat:    "45 54'N",
                      long:   "78 43'E",
                      method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece:  " 45 54'N, 78 43'E",
                      lat:    " 45 54'N, 78 43'E",
                      method: '(;)'},
           '(,)'  => {piece:  " 78 43'E; M. Hauser",
                      lat:    " 78 43'E; M. Hauser",
                      method: '(,)'},
           '( )'  => {piece:  "54'N, 43'E;",
                      lat:    "54'N,",
                      long:   "43'E;",
                      method: '( )'}
          },
        'ARGENTINA: Corrientes, P.N. Mburucuyá, 1.8 km W campgd., 80m, 28.01566o"S58.01970oW, 8 Jan 2008 C.H.Dietrich, vacuum, AR9-10'                    =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {piece:  ' 1.8 km W campgd., 28.01566o"S58.01970oW',
                      lat:    ' 1.8 km W campgd.',
                      long:   ' 28.01566o"S58.01970oW',
                      method: '(,)'},
           '( )'  => {piece:  '28.01566o"S58.01970oW,',
                      lat:    '28.01566o"S58.01970oW,',
                      method: '( )'}},

        'Dmitriev enhancement 12°27’24”N 12°27’24”W' =>
            {'DD1A' => {method: 'text, DD1A'},
             'DD1B' => {method: 'text, DD1B'},
             'DD2'  => {method: 'text, DD2'},
             'DM1'  => {method: 'text, DM1'},
             'DMS2' => {method: 'text, DMS2'},
             'DM3'  => {method: 'text, DM3'},
             'DMS4' => {method: 'text, DMS4',
                        piece:  '12°27’24”N 12°27’24”W',
                        lat:    '12°27’24”N',
                        long:   '12°27’24”W'},
             'DD5'  => {method: 'text, DD5'},
             'DD6'  => {method: 'text, DD6'},
             'DD7'  => {method: 'text, DD7'},
             '(;)'  => {method: '(;)'},
             '(,)'  => {method: '(,)'},
             '( )'  => {method: '( )',
                        piece:  '12°27’24”N 12°27’24”W',
                        lat:    '12°27’24”N',
                        long:   '12°27’24”W'}
            },

        'Dmitriev enhancement, floating point minutes 42°27.5’N 12°27.7’W' =>
            {'DD1A' => {method: 'text, DD1A'},
             'DD1B' => {method: 'text, DD1B'},
             'DD2'  => {method: 'text, DD2'},
             'DM1'  => {method: 'text, DM1',
                        piece:  '42°27.5’N 12°27.7’W',
                        lat:    '42°27.5’N',
                        long:   '12°27.7’W'},
             'DMS2' => {method: 'text, DMS2'},
             'DM3'  => {method: 'text, DM3'},
             'DMS4' => {method: 'text, DMS4'},
             'DD5'  => {method: 'text, DD5'},
             'DD6'  => {method: 'text, DD6'},
             'DD7'  => {method: 'text, DD7'},
             '(;)'  => {method: '(;)'},
             '(,)'  => {method: '(,)'},
             '( )'  => {method: '( )',
                        piece:  '42°27.5’N 12°27.7’W',
                        lat:    '42°27.5’N',
                        long:   '12°27.7’W'}
            },

        'Dmitriev enhancement, floating point minutes N42°27.5’ W12°27.7’' =>
            {'DD1A' => {method: 'text, DD1A'},
             'DD1B' => {method: 'text, DD1B'},
             'DD2'  => {method: 'text, DD2'},
             'DM1'  => {method: 'text, DM1'},
             'DMS2' => {method: 'text, DMS2'},
             'DM3'  => {method: 'text, DM3',
                        piece:  'N42°27.5’ W12°27.7’',
                        lat:    'N42°27.5’',
                        long:   'W12°27.7’'},
             'DMS4' => {method: 'text, DMS4'},
             'DD5'  => {method: 'text, DD5'},
             'DD6'  => {method: 'text, DD6'},
             'DD7'  => {method: 'text, DD7'},
             '(;)'  => {method: '(;)'},
             '(,)'  => {method: '(,)'},
             '( )'  => {method: '( )',
                        piece:  'N42°27.5’ W12°27.7’',
                        lat:    'N42°27.5’',
                        long:   'W12°27.7’'}
            },

        'Dmitriev enhancement, floating point seconds 42°27’24.5”N 12°27’24.7”W' =>
            {'DD1A' => {method: 'text, DD1A'},
             'DD1B' => {method: 'text, DD1B'},
             'DD2'  => {method: 'text, DD2'},
             'DM1'  => {method: 'text, DM1'},
             'DMS2' => {method: 'text, DMS2'},
             'DM3'  => {method: 'text, DM3'},
             'DMS4' => {method: 'text, DMS4',
                        piece:  '42°27’24.5”N 12°27’24.7”W',
                        lat:    '42°27’24.5”N',
                        long:   '12°27’24.7”W'},
             'DD5'  => {method: 'text, DD5'},
             'DD6'  => {method: 'text, DD6'},
             'DD7'  => {method: 'text, DD7'},
             '(;)'  => {method: '(;)'},
             '(,)'  => {method: '(,)'},
             '( )'  => {method: '( )',
                        piece:  '42°27’24.5”N 12°27’24.7”W',
                        lat:    '42°27’24.5”N',
                        long:   '12°27’24.7”W'}
            }
      }
      @entry    = 0

      use_cases.each { |label, result|
        @entry += 1
        specify "case #{@entry}: '#{label}' should yield #{result}" do
          use_case = Utilities::Geo.hunt_wrapper(label)
          expect(use_case).to eq(result)
        end
      }

    end

    context 'multiple use cases of degrees_minutes_seconds_to_decimal_degrees' do

      use_cases = {#' 3rd ridge prairie'            => '3.0',
                   '12°27’24”N' => '12.456667',
                   '22deg10\'34"S,' => '-22.176111', # convert deg to º
                   '166deg30\'17"E' => '166.504722',
                   '22dg10\'34"S,'  => '-22.176111', # convert deg to º
                   '166dg30\'17"E' => '166.504722',
                   '45 54\'N'      => '45.9',
                   '78 43\'E'      => '78.716667',
                   '78 43\'w'      => '-78.716667',
                   '58.0520oW,'    => '-58.052', # tolerate the trailing comma
                   '28.01795o"S' => '-28.01795',
                   'N41.87734º'  => '41.87734',
                   'W89.34677º'  => '-89.34677',
                   ' N18º '      => '18.0',
                   'W76.8º '     => '-76.8',
                   '-88.241121º' => '-88.241121', # current test case ['-88.241121°']
                   'W88.241121º' => '-88.241121', # current test case ['-88.241121°']
                   'w88∫11′43.4″' => '-88.195389',
                   'w88∫11´43.4″' => '-88.195389',
                   '40º26\'46"N'  => '40.446111', # using MAC-native symbols
                   '079º58\'56"W' => '-79.982222', # using MAC-native symbols
                   '40:26:46.302N'  => '40.446195',
                   '079:58:55.903W' => '-79.982195',
                   '40°26′46″N'     => '40.446111',
                   '079°58′56″W'    => '-79.982222',
                   '40d 26′ 46″ N'  => '40.446111',
                   '40o 26′ 46″ N'  => '40.446111',
                   '079d 58′ 56″ W' => '-79.982222',
                   '40.446195N'     => '40.446195',
                   '79.982195W'     => '-79.982195',
                   '40.446195'      => '40.446195',
                   '-79.982195'     => '-79.982195',
                   '40° 26.7717'    => '40.446195',
                   '-79° 58.93172'  => '-79.982195',
                   'N40:26:46.302'  => '40.446195',
                   'W079:58:55.903' => '-79.982195',
                   'N40°26′46″'     => '40.446111',
                   'W079°58′56″'    => '-79.982222',
                   'N40d 26′ 46″'   => '40.446111',
                   'W079d 58′ 56″'  => '-79.982222',
                   'N40.446195'     => '40.446195',
                   'W79.982195'     => '-79.982195',
                   # some special characters for Dmitry
                   '12°27’24”W'     => '-12.456667',
                   '42°27’24.5”N'   => '42.456806',
                   "  40\u02da26¥46¥S"             => '-40.446111',
                   '42∞5\'18.1"S'                  => '-42.088361',
                   'w88∞11\'43.3"'                 => '-88.195361',
                   "  42\u02da5¥18.1¥S"            => '-42.088361',
                   "  42º5'18.1'S"                 => '-42.088361',
                   "  42o5\u02b918.1\u02b9\u02b9S" => '-42.088361',
                   'w88∫11′43.3″'                  => '-88.195361',
                   # weird things that might break the converter...
                   -10             => '-10.0',
                   '-11'           => '-11.0',
                   'bad_data-10'   => nil,
                   'bad_data-10.1' => nil,
                   'nan'           => nil,
                   'NAN'           => nil}

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

      @entry = 0

      use_cases.each { |co_ordinate, result|
        @entry += 1
        specify "case #{@entry}: '#{co_ordinate}' should yield #{result}" do
          use_case = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(co_ordinate)
          expect(use_case).to eq(result)
        end
      }
    end
  end

  context 'adjusting digits from params[] to 1-2-5 sequence' do
    let(:near) { 'nearby_distance' }
    let(:params) { {near => '0', 'digit1' => '0', 'digit2' => '0'} }
    let(:garbage) { 'inconsistant input value' }
    let(:two_fifty) { '250' }
    let(:five_k) { '5000' }
    let(:one_to_5) { '12345' }
    let(:one_sixty_five_k) { '165432' }

    context 'garbage converts to 5000, 5, 1000' do

      specify 'distance' do
        params[near] = garbage
        result       = Utilities::Geo.nearby_from_params(params)
        expect(result).to eq(5_000)
      end

      specify 'digit1' do
        params[near] = garbage
        Utilities::Geo.nearby_from_params(params)
        expect(params['digit1']).to eq('5')
      end

      specify 'digit2' do
        params[near] = garbage
        Utilities::Geo.nearby_from_params(params)
        expect(params['digit2']).to eq('1000')
      end
    end

    context '250 converts to 500, 5, 100' do

      specify 'distance' do
        params[near] = two_fifty
        result       = Utilities::Geo.nearby_from_params(params)
        expect(result).to eq(500)
      end

      specify 'digit1' do
        params[near] = two_fifty
        Utilities::Geo.nearby_from_params(params)
        expect(params['digit1']).to eq('5')
      end

      specify 'digit2' do
        params[near] = two_fifty
        Utilities::Geo.nearby_from_params(params)
        expect(params['digit2']).to eq('100')
      end
    end

    context '5000 converts to 5000, 5, 1000' do

      specify 'distance' do
        params[near] = five_k
        result       = Utilities::Geo.nearby_from_params(params)
        expect(result).to eq(5_000)
      end

      specify 'digit1' do
        params[near] = two_fifty
        Utilities::Geo.nearby_from_params(params)
        expect(params['digit1']).to eq('5')
      end

      specify 'digit2' do
        params[near] = two_fifty
        Utilities::Geo.nearby_from_params(params)
        expect(params['digit2']).to eq('100')
      end
    end

    context '12345 converts to 20000, 2, 10000' do

      specify 'distance' do
        params[near] = one_to_5
        result       = Utilities::Geo.nearby_from_params(params)
        expect(result).to eq(10_000)
      end

      specify 'digit1' do
        params[near] = one_to_5
        Utilities::Geo.nearby_from_params(params)
        expect(params['digit1']).to eq('1')
      end

      specify 'digit2' do
        params[near] = one_to_5
        Utilities::Geo.nearby_from_params(params)
        expect(params['digit2']).to eq('10000')
      end
    end

    context '165432 converts to 200000, 2, 100000' do

      specify 'distance' do
        params[near] = one_sixty_five_k
        result       = Utilities::Geo.nearby_from_params(params)
        expect(result).to eq(200_000)
      end

      specify 'digit1' do
        params[near] = one_sixty_five_k
        Utilities::Geo.nearby_from_params(params)
        expect(params['digit1']).to eq('2')
      end

      specify 'digit2' do
        params[near] = one_sixty_five_k
        Utilities::Geo.nearby_from_params(params)
        expect(params['digit2']).to eq('100000')
      end
    end
  end

  context 'elevation_in_meters' do
    context 'single use cases' do
      specify "case '123 miles' should yield #{197_949.312}" do
        # expect(Utilities::Geo.distance_in_meters('123 mi.').to_f).to eq(198_000)    # was 197_949.312
        expect(Utilities::Geo.distance_in_meters('')).to eq('0')
        # expect(Utilities::Geo.distance_in_meters('2.0000000 miles')).to eq('3218.6880')
      end
    end

    context 'multiple use cases as string values' do
      use_cases = {' 12345'                => '12345', # .0
                   '1.1 mi'                => '1800', #1770.2784
                   '1.10 mi'               => '1770',
                   '1.100 mi'              => '1770',
                   '1.1000 mi'             => '1770.3',
                   '1.10000 mi'            => '1770.28',
                   '2 mile'                => '3000', #3218.688
                   '2. mile'               => '3000',
                   '2.0 mile'              => '3200',
                   '2.00 mile'             => '3220',
                   '2.000 mile'            => '3219',          ##### @mjy ambiguous decimal point 3219. -> 3219
                   '2.0000 mile'           => '3218.7',
                   '2.00000 mile'          => '3218.69',
                   '2.000000 mile'         => '3218.688',
                   '2.0000000 mile'        => '3218.6880',    ##### @mjy more significant digits than product fixed
                   '3 miles'               => '5000', #4828.032,
                   '.03 mi'                => '50',
                   '.030 mi'               => '48',   #               ##### @mjy ambiguous decimal point  48. -> 48
                   '.0300 mi'              => '48.3',
                   '.03000 mi'             => '48.28',
                   '0.03 mi'               => '50',
                   '0.030 mi'              => '48',   #               ##### @mjy ambiguous decimal point  48. -> 48
                   '0.0300 mi'             => '48.3',
                   '0.03000 mi'            => '48.28',
                   '0.030000 mi'           => '48.280',
                   '0.0300000 mi'          => '48.2803',
                   '0.3000000 mi'          => '482.8032',
                   '0.30000000 mi'         => '482.80320',
                   '3036m'                 => '3036',
                   '2.11km'                => '2110',
                   ' 123.45'               => '123.45',
                   ' 123 ft'               => '37.5',    #37.4904
                   ' 123 ft.'              => '37.5',
                   ' 123 feet'             => '37.5',
                   ' 1 foot'               => '0.3',     #0.3048,     ##### @mjy ambiguous (missing) single lead 0 before mantissa
                   ' 123 f'                => '37.5',                      ## ^ .3 now computes to 0.3 (valid Ruby number)
                   '   123 f.'             => '37.5',
                   '   123f.'              => '37.5',    #37.4904
                   '   123ft.'             => '37.5',
                   '   123.0ft.'           => '37.49',
                   ' 123.0000000 mi'       => '197949.3120',
                   ' 123 m'                => '123',
                   '  123 meters'          => '123',
                   '     123 m.'           => '123',
                   '    123 km'            => '123000',
                   ' 123 km.'              => '123000',
                   '       123 kilometers' => '123000',
                   '123 kilometer'         => '123000',
                   ''                      => '0',          #         ##### ambiguous/erroneous leading decimal point fixed
                   'sillyness'             => '0',
                   'No. N0t a number.'     => '0'}

      @entry = 0

      use_cases.each { |distance, result|
        @entry += 1
        specify "case #{@entry}: '#{distance}' should yield #{result}" do
          expect(Utilities::Geo.distance_in_meters(distance)).to eq(result)
        end
      }
    end

    context 'significant digits analysis' do
      use_cases = {
          '1' =>         ['1', 1, '1', '', '', ''],
          '1.' =>        ['1.', 1, '1', '.', '', ''],
          '1.0' =>       ['1.0', 2, '1', '.', '', '0'],
          '1.00' =>      ['1.00', 3, '1', '.', '', '00'],
          '1.000' =>     ['1.000', 4, '1', '.', '', '000'],
          '1.0000' =>    ['1.0000', 5, '1', '.', '', '0000'],
          '1.2' =>       ['1.2', 2, '1', '.', '', '2'],
          '123' =>       ['123', 3, '123', '', '', ''],
          '.2' =>        ['.2', 1, '', '.', '', '2'],
          '.0002' =>     ['.0002', 1, '', '.', '000', '2'],
          '0.0002' =>    ['.0002', 1, '', '.', '000', '2'],
          '0.00020' =>   ['.00020', 2, '', '.', '000', '20'],
          '1.00020' =>   ['1.00020', 6, '1', '.', '', '00020'],
          '12.00020' =>  ['12.00020', 7, '12', '.', '', '00020'],
          '123.00020' => ['123.00020', 8, '123', '.', '', '00020'],
          }

      @entry = 0

      use_cases.each { |number, result|
        @entry += 1
        specify "case #{@entry}: '#{number}' should yield #{result}" do
          # expect(Utilities::Geo.distance_in_meters(distance)).to be_within(0.1).of(result)
          expect(Utilities::Geo.significant_digits(number.to_s)).to eq(result)
        end
      }
    end

    context 'significant digits conformance' do
      use_cases = {
          '12345'     => ['12345', 5],
          '1770.2784' => ['1800',2],
          '3218.688'  => ['3000', 1],
          '4828.032'  => ['5000', 1],
          '3036'      => ['3036', 4],
          '2110'      => ['2110', 3],
          '123.45'    => ['123.45', 5],
          '37.4904'   => ['37.5', 3],
          '0.3048'    => ['0.3', 1],
          '123.00020' => ['123.00', 5]
      }

      @entry = 0

      use_cases.each { |number, result|
        @entry += 1
        specify "case #{@entry}: '#{number}', '#{result[1]}' should yield #{result[0]}" do
          expect(Utilities::Geo.conform_significant(number, result[1])).to eq(result[0])
        end
      }
    end

  end
  # rubocop:enable Style/StringHashKeys

  context 'test coordinates_regex_from_verbatim_label' do
    context 'multiple use cases in coordinates_regex_from_verbatim_label' do

      use_cases = {
                   'text, 20.2501ºN 105.7145ºE 156m text'     => '20.2501///N/105.7145///E',
                   'text, 42°5ʼ18.1"S 88°11ʼ43.3"W, text'     => '42/5/18.1/S/88/11/43.3/W',
                   'text, 00°39’25.7” S 076°27’10.8” W, text' => '00/39/25.7/S/076/27/10.8/W',
                   'text, 19°8′31″ S 44°49′41″ E, text'       => '19/8/31/S/44/49/41/E',
                   'text, S42°5ʼ18.1"W88°11ʼ43.3", text'      => '42/5/18.1/S/88/11/43.3/W',
                   'text, S42°5.18ʼW88°11.43ʼ, text'          => '42/5.18//S/88/11.43//W',
                   'text, N04°54.028’ W052°34.494’, text'     => '04/54.028//N/052/34.494//W',
                   'text, 11°25΄ N 107°25΄ E, text'           => '11/25//N/107/25//E',
                   'text, 42°5.18ʼS88°11.43ʼW, text'          => '42/5.18//S/88/11.43//W',
                   'text, 29º 28.667’S 30º 15.701’ E, text'   => '29/28.667//S/30/15.701//E',
                   'text, 23°41.19′ S, 44°35.46′ E, text'     => '23/41.19//S/44/35.46//E',
                   'text, 10°32’S, 75°21’W, text'             => '10/32//S/75/21//W',
                   'text, S42.18°W88.34°, text'               => '42.18///S/88.34///W',
                   'text, 42.18°S88.34°W, text'               => '42.18///S/88.34///W',
                   'text, -12.263, 49.398, text'              => '12.263///S/49.398///E',
                   'text, 35.1026ºN  85.2718ºW, text'         => '35.1026///N/85.2718///W', # double space
                   "text, 35.1026ºN\n85.2718ºW, text"         => '35.1026///N/85.2718///W', # line break
                   'text, 12, -123, text'                     => '12///N/123///W',
      }

      @entry = 0

      use_cases.each { |co_ordinate, result|
        @entry += 1
        specify "case #{@entry}: '#{co_ordinate}' should yield #{result}" do
          use_case = Utilities::Geo.coordinates_regex_from_verbatim_label(co_ordinate)
          u = use_case[:parsed][:lat_deg].to_s + '/' +
              use_case[:parsed][:lat_min].to_s + '/' +
              use_case[:parsed][:lat_sec].to_s + '/' +
              use_case[:parsed][:lat_ns].to_s + '/' +
              use_case[:parsed][:long_deg].to_s + '/' +
              use_case[:parsed][:long_min].to_s + '/' +
              use_case[:parsed][:long_sec].to_s + '/' +
              use_case[:parsed][:long_we].to_s

          expect(u).to eq(result)
        end
      }
    end

    context 'coordinates_regex_from_verbatim_label values' do
      specify 'strings 1' do
        str = 'text, S42°5ʼ18.1" W88°11ʼ43.3", text'
        use_case = Utilities::Geo.coordinates_regex_from_verbatim_label(str)
        u = use_case[:verbatim][:verbatim_latitude] + '/' + use_case[:verbatim][:verbatim_longitude]
        expect(u).to eq("42°5'18.1\"S/88°11'43.3\"W")
      end

      specify 'strings 2' do
        str = 'text, -12.263, 49.398, text'
        use_case = Utilities::Geo.coordinates_regex_from_verbatim_label(str)
        u = use_case[:verbatim][:verbatim_latitude] + '/' + use_case[:verbatim][:verbatim_longitude]
        expect(u).to eq("-12.263/49.398")
      end

      specify 'decimal' do
        str = 'text, S42°5ʼ18.1" W88°11ʼ43.3", text'
        use_case = Utilities::Geo.coordinates_regex_from_verbatim_label(str)
        u = use_case[:decimal][:decimal_latitude] + '/' + use_case[:decimal][:decimal_longitude]
        expect(u).to eq("-42.088361/-88.195361")
      end
    end
  end


end
