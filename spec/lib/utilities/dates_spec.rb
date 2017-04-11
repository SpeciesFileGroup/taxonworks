require 'rails_helper'
# rubocop:disable Style/AsciiComments, Style/EmptyLinesAroundBlockBody

# TODO: Extract all this to a gem
describe 'Dates', group: [:collecting_events, :dates] do

  context 'date discovery and parsing' do

    context 'bad values' do

      specify 'truley bogus data' do
        this_case = Utilities::Dates.hunt_dates('192:5:18.1N')

        expect(this_case).to eq(
                               {"MONTH_DD_YYYY_2"        => {:method => "MONTH_DD_YYYY_2"},
                                "DD_MONTH_YYYY_2"        => {:method => "DD_MONTH_YYYY_2"},
                                "MM_DD_YYYY_2"           => {:method => "MM_DD_YYYY_2"},
                                "MONTH_DD_MONTH_DD_YYYY" => {:method => "MONTH_DD_MONTH_DD_YYYY"},
                                "DD_MONTH_DD_MONTH_YYYY" => {:method => "DD_MONTH_DD_MONTH_YYYY"},
                                "MM_DD_MM_DD_YYYY"       => {:method => "MM_DD_MM_DD_YYYY"},
                                "MONTH_DD_DD_YYYY"       => {:method => "MONTH_DD_DD_YYYY"},
                                "DD_DD_MONTH_YYYY"       => {:method => "DD_DD_MONTH_YYYY"},
                                "MM_DD_DD_YYYY"          => {:method => "MM_DD_DD_YYYY"},
                                "MONTH_DD_YYY"           => {:method => "MONTH_DD_YYY"},
                                "DD_MONTH_YYY"           => {:method => "DD_MONTH_YYY"},
                                "MM_DD_YYYY"             => {:method => "MM_DD_YYYY"},
                                "MM_DD_YY"               => {:method => "MM_DD_YY"}
                               }
                             )
      end
    end

    context 'single use case for dates hunt_dates' do
      use_case = {'Some text here,  5 V 2003, some more text after the date  ' =>
                    {"MONTH_DD_YYYY_2"        => {:method => "MONTH_DD_YYYY_2"},
                     "DD_MONTH_YYYY_2"        => {:method => "DD_MONTH_YYYY_2"},
                     "MM_DD_YYYY_2"           => {:method => "MM_DD_YYYY_2"},
                     "MONTH_DD_MONTH_DD_YYYY" => {:method => "MONTH_DD_MONTH_DD_YYYY"},
                     "DD_MONTH_DD_MONTH_YYYY" => {:method => "DD_MONTH_DD_MONTH_YYYY"},
                     "MM_DD_MM_DD_YYYY"       => {:method => "MM_DD_MM_DD_YYYY"},
                     "MONTH_DD_DD_YYYY"       => {:method => "MONTH_DD_DD_YYYY"},
                     "DD_DD_MONTH_YYYY"       => {:method => "DD_DD_MONTH_YYYY"},
                     "MM_DD_DD_YYYY"          => {:method => "MM_DD_DD_YYYY"},
                     "MONTH_DD_YYY"           => {:method => "MONTH_DD_YYY"},
                     "DD_MONTH_YYY"           => {:piece            => "5 V 2003",
                                                  :method           => "DD_MONTH_YYY",
                                                  :start_date_year  => "2003",
                                                  :start_date_month => "5",
                                                  :start_date_day   => "5",
                                                  :start_date       => "2003/5/5",
                                                  :end_date_year    => "",
                                                  :end_date_month   => "",
                                                  :end_date_day     => "",
                                                  :end_date         => "//"},
                     "MM_DD_YYYY"             => {:method => "MM_DD_YYYY"},
                     "MM_DD_YY"               => {:method => "MM_DD_YY"}}
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

    context 'multiple use cases for dates hunt_dates' do
      use_cases = {
        'Here is some extra text: 4 jan, 2017  More stuff at the end'      =>
          {"MONTH_DD_YYYY_2"        => {:method => "MONTH_DD_YYYY_2"},
           "DD_MONTH_YYYY_2"        => {:method => "DD_MONTH_YYYY_2"},
           "MM_DD_YYYY_2"           => {:method => "MM_DD_YYYY_2"},
           "MONTH_DD_MONTH_DD_YYYY" => {:method => "MONTH_DD_MONTH_DD_YYYY"},
           "DD_MONTH_DD_MONTH_YYYY" => {:method => "DD_MONTH_DD_MONTH_YYYY"},
           "MM_DD_MM_DD_YYYY"       => {:method => "MM_DD_MM_DD_YYYY"},
           "MONTH_DD_DD_YYYY"       => {:method => "MONTH_DD_DD_YYYY"},
           "DD_DD_MONTH_YYYY"       => {:method => "DD_DD_MONTH_YYYY"},
           "MM_DD_DD_YYYY"          => {:method => "MM_DD_DD_YYYY"},
           "MONTH_DD_YYY"           => {:method => "MONTH_DD_YYY"},
           "DD_MONTH_YYY"           => {:piece            => "4 jan, 2017",
                                        :method           => "DD_MONTH_YYY",
                                        :start_date_year  => "2017",
                                        :start_date_month => "1",
                                        :start_date_day   => "4",
                                        :start_date       => "2017/1/4",
                                        :end_date_year    => "",
                                        :end_date_month   => "",
                                        :end_date_day     => "",
                                        :end_date         => "//"},
           "MM_DD_YYYY"             => {:method => "MM_DD_YYYY"},
           "MM_DD_YY"               => {:method => "MM_DD_YY"}
          },
        'Here is some extra text:,;   22-23 V 2003; More stuff at the end' =>
          {"MONTH_DD_YYYY_2"        => {:method => "MONTH_DD_YYYY_2"},
           "DD_MONTH_YYYY_2"        => {:method => "DD_MONTH_YYYY_2"},
           "MM_DD_YYYY_2"           => {:method => "MM_DD_YYYY_2"},
           "MONTH_DD_MONTH_DD_YYYY" => {:method => "MONTH_DD_MONTH_DD_YYYY"},
           "DD_MONTH_DD_MONTH_YYYY" => {:method => "DD_MONTH_DD_MONTH_YYYY"},
           "MM_DD_MM_DD_YYYY"       => {:method => "MM_DD_MM_DD_YYYY"},
           "MONTH_DD_DD_YYYY"       => {:method => "MONTH_DD_DD_YYYY"},
           "DD_DD_MONTH_YYYY"       => {:piece            => "22-23 V 2003",
                                        :method           => "DD_DD_MONTH_YYYY",
                                        :start_date_year  => "2003",
                                        :start_date_month => "5",
                                        :start_date_day   => "22",
                                        :start_date       => "2003/5/22",
                                        :end_date_year    => "2003",
                                        :end_date_month   => "5",
                                        :end_date_day     => "23",
                                        :end_date         => "2003/5/23"},
           "MM_DD_DD_YYYY"          => {:method => "MM_DD_DD_YYYY"},
           "MONTH_DD_YYY"           => {:method => "MONTH_DD_YYY"},
           "DD_MONTH_YYY"           => {:piece            => "23 V 2003",
                                        :method           => "DD_MONTH_YYY",
                                        :start_date_year  => "2003",
                                        :start_date_month => "5",
                                        :start_date_day   => "23",
                                        :start_date       => "2003/5/23",
                                        :end_date_year    => "",
                                        :end_date_month   => "",
                                        :end_date_day     => "",
                                        :end_date         => "//"},
           "MM_DD_YYYY"             => {:method => "MM_DD_YYYY"},
           "MM_DD_YY"               => {:method => "MM_DD_YY"}
          }
      }
      @entry    = 0

      use_cases.each {|label, result|
        @entry += 1
        specify "case #{@entry}: #{label} should yield #{result}" do
          this_case = Utilities::Dates.hunt_dates(label)
          expect(this_case).to eq(result)
        end
      }

    end
  end
end
