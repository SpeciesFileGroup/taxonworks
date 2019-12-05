require 'rails_helper'

# Vast majority of functionality is derived from related models. 
describe Queries::Otu::Autocomplete, type: :model do
  let!(:otu) { Otu.create(name: 'Test') }
  let(:query) { Queries::Otu::Autocomplete.new('Test') }

  specify 'named' do
    expect(query.autocomplete).to include(otu)
  end
end
