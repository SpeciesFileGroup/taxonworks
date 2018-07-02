require 'rails_helper'

describe Queries::Otu::Autocomplete, type: :model do

  let(:query) { Queries::Otu::Autocomplete.new('') }

  context 'methods' do

    specify '#authorship 1' do
      query.query_string = 'Aus bus Smith'
      expect(query.authorship).to eq('Smith') 
    end

    specify '#authorship 2' do
      query.query_string = 'Aus bus 1'
      expect(query.authorship).to eq(nil) 
    end

    specify '#authorship 3' do
      query.query_string = 'Semiotellus species 1'
      expect(query.authorship).to eq(nil) 
    end
  end 

end
