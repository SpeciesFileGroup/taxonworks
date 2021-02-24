# TODO: Extract all this to a gem

# TODO: by definition of being in Utilities this shouldn't be required
require 'rails_helper'

describe Utilities::Dates, group: [:collecting_events, :dates] do

  let(:lib) { Utilities::Dates }

  let(:today) { Time.zone.today.strftime('%Y-%m-%d') }

  specify '.order_dates 1' do
    a = %w{1932-01-11 1859-01-22}
    expect(lib.order_dates(a[0], a[1])).to eq([a[1], a[0]]) 
  end

  specify '.order_dates 2' do
    a = %w{1932/01/11 1859/01/22}
    expect(lib.order_dates(a[0], a[1])).to eq([a[1], a[0]]) 
  end

  specify '.normalize_and_order_dates 1' do
    a = %w{1932/01/11 1859/01/22}
    expect(lib.normalize_and_order_dates(a[0], a[1])).to eq([a[1], a[0]]) 
  end

  specify '.normalize_and_order_dates 2' do
    a = %w{1932/01/11 1859/01/22}
    expect(lib.normalize_and_order_dates(a[0], nil)).to eq([ a[0], a[0] ]) 
  end

  specify '.normalize_and_order_dates 2' do
    expect(lib.normalize_and_order_dates(nil, nil)).to eq([ Utilities::Dates::EARLIEST_DATE, today ]) 
  end

  context 'date discovery and parsing' do
    context 'bad values' do

      specify 'truley bogus data' do
        this_case = Utilities::Dates.hunt_dates('192:5:18.1N')

        expect(this_case).to eq(
                                 {dd_dd_month_yyyy: {},
                                  dd_mm_dd_mm_yyyy: {},
                                  dd_month_dd_month_yyyy: {},
                                  dd_month_yyy: {},
                                  dd_month_yyyy_2: {},
                                  mm_dd_dd_yyyy: {},
                                  mm_dd_mm_dd_yyyy: {},
                                  mm_dd_yy: {},
                                  dd_mm_yy: {},
                                  mm_dd_yyyy: {},
                                  mm_dd_yyyy_2: {},
                                  month_dd_dd_yyyy: {},
                                  month_dd_month_dd_yyyy: {},
                                  month_dd_yyy: {},
                                  month_dd_yyyy_2: {},
                                  yyyy_mm_dd: {},
                                  yyy_mm_dd: {},
                                  yyyy_month_dd: {},
                                  yyyy_mm_dd_mm_dd: {},
                                  yyyy_month_dd_month_dd: {}
                                 }
                             )
      end
    end
    
    #done except failing on 'This is a test september 20 ,1944 - November 19 , 1945' (extra spaces)
    context 'single use case for dates hunt_dates' do
      use_case = {'Some text here,  5 V 2003, some more text after the date  ' =>
                      {dd_dd_month_yyyy: {},
                       dd_mm_dd_mm_yyyy: {},
                       dd_month_dd_month_yyyy: {},
                       dd_month_yyy: {method: :dd_month_yyy, piece: {0 => '5 V 2003'}, start_date_year: '2003', start_date_month: '5', start_date_day: '5', end_date_year: '', end_date_month: '', end_date_day: '', start_date: '2003 5 5', end_date: ''},
                       dd_month_yyyy_2: {},
                       mm_dd_dd_yyyy: {},
                       mm_dd_mm_dd_yyyy: {},
                       mm_dd_yy: {},
                       dd_mm_yy: {},
                       mm_dd_yyyy: {},
                       mm_dd_yyyy_2: {},
                       month_dd_dd_yyyy: {},
                       month_dd_month_dd_yyyy: {},
                       month_dd_yyy: {},
                       month_dd_yyyy_2: {},
                       yyyy_mm_dd: {},
                       yyy_mm_dd: {},
                       yyyy_month_dd: {},
                       yyyy_mm_dd_mm_dd: {},
                       yyyy_month_dd_month_dd: {}
                      }
      }
      @entry   = 0

      use_case.each {|label, result|
        @entry += 1
        specify "case #{@entry}: #{label} should yield #{result}" do
          this_case = Utilities::Dates.hunt_dates(label)
          expect(this_case).to eq(result)
        end
      }
    end

    context 'two digit year use case for dates hunt_dates' do
      use_case = {"Some text here,  4 JUL '03, some more text after the date  " =>
                      {dd_dd_month_yyyy: {},
                       dd_mm_dd_mm_yyyy: {},
                       dd_month_dd_month_yyyy: {},
                       dd_month_yyy: {method: :dd_month_yyy, piece: {0 => "4 JUL '03"}, start_date_year: '2003', start_date_month: '7', start_date_day: '4', end_date_year: '', end_date_month: '', end_date_day: '', start_date: '2003 7 4', end_date: ''},
                       dd_month_yyyy_2: {},
                       mm_dd_dd_yyyy: {},
                       mm_dd_mm_dd_yyyy: {},
                       mm_dd_yy: {},
                       dd_mm_yy: {},
                       mm_dd_yyyy: {},
                       mm_dd_yyyy_2: {},
                       month_dd_dd_yyyy: {},
                       month_dd_month_dd_yyyy: {},
                       month_dd_yyy: {},
                       month_dd_yyyy_2: {},
                       yyyy_mm_dd: {},
                       yyy_mm_dd: {},
                       yyyy_month_dd: {},
                       yyyy_mm_dd_mm_dd: {},
                       yyyy_month_dd_month_dd: {}
                      }
      }
      @entry = 0

      use_case.each {|label, result|
        @entry += 1
        specify "case #{@entry}: #{label} should yield #{result}" do
          this_case = Utilities::Dates.hunt_dates(label)
          expect(this_case).to eq(result)
        end
      }
    end

    context 'use one regex method at a time in hunt_dates against the set of its examples' do
      methods = Utilities::Dates::REGEXP_DATES.keys
      methods.each_with_index {|method, dex|
        this_hlp = Utilities::Dates::REGEXP_DATES[method][:hlp]
        matches = this_hlp.split(' | ')
        matches.each {|this_match|

          specify "method  #{method} should correctly match each  #{this_match} example listed in the hlp attribute " do
            this_case = Utilities::Dates.hunt_dates(this_match, [method])
            verbatim_date = Utilities::Dates.make_verbatim_date_piece(this_match, this_case[method][:piece])
            expect(verbatim_date).to eq(this_match.strip)
          end
        }
      }
    end

    context 'multiple use cases for dates hunt_dates' do
      use_cases = {
          "Here is some extra text: 4 jan, '17  More stuff at the end" =>
              {dd_dd_month_yyyy: {},
               dd_mm_dd_mm_yyyy: {},
               dd_month_dd_month_yyyy: {},
               dd_month_yyy: {method: :dd_month_yyy, piece: {0 => "4 jan, '17"}, start_date_year: '2017', start_date_month: '1', start_date_day: '4', end_date_year: '', end_date_month: '', end_date_day: '', start_date: '2017 1 4', end_date: ''},
               dd_month_yyyy_2: {},
               mm_dd_dd_yyyy: {},
               mm_dd_mm_dd_yyyy: {},
               mm_dd_yy: {},
               dd_mm_yy: {},
               mm_dd_yyyy: {},
               mm_dd_yyyy_2: {},
               month_dd_dd_yyyy: {},
               month_dd_month_dd_yyyy: {},
               month_dd_yyy: {},
               month_dd_yyyy_2: {},
               yyyy_mm_dd: {},
               yyy_mm_dd: {},
               yyyy_month_dd: {},
               yyyy_mm_dd_mm_dd: {},
               yyyy_month_dd_month_dd: {}
              },
          'Here is some extra text:,;   22-23 V 2003; More stuff at the end' =>
              {dd_dd_month_yyyy: {method: :dd_dd_month_yyyy, piece: {0 => '22-23 V 2003'}, start_date_year: '2003', start_date_month: '5', start_date_day: '22', end_date_year: '2003', end_date_month: '5', end_date_day: '23', start_date: '2003 5 22', end_date: '2003 5 23'},
               dd_mm_dd_mm_yyyy: {},
               dd_month_dd_month_yyyy: {},
               dd_month_yyy: {method: :dd_month_yyy, piece: {0 => '23 V 2003'}, start_date_year: '2003', start_date_month: '5', start_date_day: '23', end_date_year: '', end_date_month: '', end_date_day: '', start_date: '2003 5 23', end_date: ''},
               dd_month_yyyy_2: {},
               mm_dd_dd_yyyy: {},
               mm_dd_mm_dd_yyyy: {},
               mm_dd_yy: {},
               dd_mm_yy: {},
               mm_dd_yyyy: {},
               mm_dd_yyyy_2: {},
               month_dd_dd_yyyy: {},
               month_dd_month_dd_yyyy: {},
               month_dd_yyy: {},
               month_dd_yyyy_2: {},
               yyyy_mm_dd: {},
               yyy_mm_dd: {},
               yyyy_month_dd: {method: :yyyy_month_dd, piece: {0 => '23 V 20'}, start_date_year: '1923', start_date_month: '5', start_date_day: '20', end_date_year: '', end_date_month: '', end_date_day: '', start_date: '1923 5 20', end_date: ''},
               yyyy_mm_dd_mm_dd: {},
               yyyy_month_dd_month_dd: {}
              }
      }
      @entry = 0

      use_cases.each {|label, result|
        @entry += 1
        specify "case #{@entry}: #{label} should yield #{result}" do
          this_case = Utilities::Dates.hunt_dates(label)
          expect(this_case).to eq(result)
        end
      }

    end
  end

  context 'test date_regex_from_verbatim_label' do
    context 'multiple use cases in date_regex_from_verbatim_label' do

      use_cases = {
          'text, June 27 1946 - July 1 1947, text' => '27/6/1946/1/7/1947',
          'text, June 27, 1946 - July 1, 1947, text' => '27/6/1946/1/7/1947',
          'text, 27 June 1946 - 1 July 1947, text' => '27/6/1946/1/7/1947',
          'text, 27 VI 1946 - 1 VII 1947, text' => '27/6/1946/1/7/1947',
          'text, 27VI1946 - 1VII1947, text' => '27/6/1946/1/7/1947',
          'text, 27-VI-1946 - 1-VII-1947, text' => '27/6/1946/1/7/1947',
          'text, 5 27 1946 - 6 1 1947, text' => '27/5/1946/1/6/1947',
          'text, June 27 - July 1 1947, text' => '27/6/1947/1/7/1947',
          'text, VII-30-VIII-17-2000, text' => '30/7/2000/17/8/2000',
          'text, 27 June - 1 July 1947, text' => '27/6/1947/1/7/1947',
          'text, 27 VI - 1 VII 1947, text' => '27/6/1947/1/7/1947',
          'text, 27-VI - 1-VII-1947, text' => '27/6/1947/1/7/1947',
          'text, 27VI - 1VII1947, text' => '27/6/1947/1/7/1947',
          'text, 5 27 - 6 1 1947, text' => '27/5/1947/1/6/1947',
          'text, June 27-29 1947, text' => '27/6/1947/29/6/1947',
          'text, 27-29 June 1947, text' => '27/6/1947/29/6/1947',
          'text, 8–12.07.2019, text' => '8/07/2019/12/07/2019',
          'text, 12 27-29 1947, text' => '27/12/1947/29/12/1947',
          'text, 20/XI/2018, text' => '20/11/2018///',
          'text, Jun 29 1947, text' => '29/6/1947///',
          'text, Jun 29, 1947, text' => '29/6/1947///',
          'text, June 29, 1947, text' => '29/6/1947///',
          'text, VI-29-1947, text' => '29/6/1947///',
          'text, X.25.2000, text' => '25/10/2000///',
          "text, Jun 29, '47, text" => '29/6/1947///',
          "text, June 29, '47, text" => '29/6/1947///',
          'text, VI-4-08, text' => '4/6/1908///',
          'text, 29 Jun 1947, text' => '29/6/1947///',
          'text, 29 June 1947, text' => '29/6/1947///',
          'text, 2 June, 1983, text' => '2/6/1983///',
          'text, 29 VI 1947, text' => '29/6/1947///',
          'text, 29-VI-1947, text' => '29/6/1947///',
          'text, 25.X.2000, text' => '25/10/2000///',
          'text, 25X2000, text' => '25/10/2000///',
          "text, 29 June '47, text" => '29/6/1947///',
          "text, 29 Jun '47, text" => '29/6/1947///',
          'text, 6/29/1947, text' => '29/6/1947///',
          'text, 6-29-1947, text' => '29/6/1947///',
          'text, 6-15 1985, text' => '15/6/1985///',
          'text, 10.25 2000, text' => '25/10/2000///',
          'text, 7.10.1994, text' => '10/7/1994///',
          'text, 6/29/47, text' => '29/6/1947///',
          "text, 6/29/'47, text" => '29/6/1947///',
          "text, 7.10.94, text" => '10/7/1894///',
          "text, 5-17-97, text" => '17/5/1897///',
          'text, Jun - Jul 1947, text' => '/6/1947//7/1947',
          'text, June - July, 1947, text' => '/6/1947//7/1947',
          'text, VI-X 1947, text' => '/6/1947//10/1947',
          'text, Jun 1947, text' => '/6/1947///',
          'text, June, 1947, text' => '/6/1947///',
          'text, VI 1947, text' => '/6/1947///',
      }

      @entry = 0

      use_cases.each { |co_ordinate, result|
        @entry += 1
        specify "case #{@entry}: '#{co_ordinate}' should yield #{result}" do
          use_case = Utilities::Dates.date_regex_from_verbatim_label(co_ordinate)
          u = use_case[:start_date_day].to_s + '/' +
              use_case[:start_date_month].to_s + '/' +
              use_case[:start_date_year].to_s + '/' +
              use_case[:end_date_day].to_s + '/' +
              use_case[:end_date_month].to_s + '/' +
              use_case[:end_date_year].to_s

          expect(u).to eq(result)
        end
      }
    end
  end

end
