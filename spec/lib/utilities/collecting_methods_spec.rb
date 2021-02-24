require 'rails_helper'

describe 'collecting_methods', group: :collecting_event do

  context 'multiple use cases in method_regex_from_verbatim_label' do

    use_cases = {
        'text, malaise, text' => 'Malaise trap',
        'text, blacklight trap, text'  => 'black light trap',
        'text, handpick text'      => 'hand collecting', }

    @entry = 0

    use_cases.each { |co_ordinate, result|
      @entry += 1
      specify "case #{@entry}: '#{co_ordinate}' should yield #{result}" do
        use_case = Utilities::CollectingMethods.method_regex_from_verbatim_label(co_ordinate)
        u = use_case[:verbatim_method].to_s

        expect(u).to eq(result)
      end
    }
  end
end