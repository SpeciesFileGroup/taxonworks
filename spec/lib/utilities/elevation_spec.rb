require 'rails_helper'

describe 'Elevation', group: :collecting_event do

  context 'multiple use cases in elevation_regex_from_verbatim_label' do

    use_cases = {
        'text, 10 ft, text' => '3.05//m',
        'text, 10-20 ft., text'  => '3.05/6.1/m',
        'text, 25m text'      => '25//m',
        'text, 1,025m text'      => '1025//m',
        'text, 1,000 - 2,000 ft. text'      => '304.8/609.6/m',
        'approx. 1500 meters' => '1500//m',
        'text, 100 feet and more text' => '30.48//m',
        'text, 100 feet. And more text' => '30.48//m'
    }

    @entry = 0

    use_cases.each { |co_ordinate, result|
      @entry += 1
      specify "case #{@entry}: '#{co_ordinate}' should yield #{result}" do
        use_case = Utilities::Elevation.elevation_regex_from_verbatim_label(co_ordinate)
        u = use_case[:minimum_elevation].to_s + '/' + use_case[:maximum_elevation].to_s + '/' + use_case[:units].to_s

        expect(u).to eq(result)
      end
    }
  end

  context 'invalid verbatim elevation tests' do
    specify "should return empty hash if no numbers found" do
      expect(Utilities::Elevation.elevation_regex_from_verbatim_label("only text here!")).to be_empty

    end

  end
end
