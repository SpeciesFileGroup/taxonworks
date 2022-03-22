require 'rails_helper'

describe Queries::Extract::Autocomplete, type: :model do
  let!(:extract) { FactoryBot.create(:valid_extract) }

  let(:other_project) { FactoryBot.create(:valid_project, name: 'other') }

  specify 'no match' do
    query = Queries::Extract::Autocomplete.new('zzz') 
    expect(query.autocomplete).to be_empty
  end

  specify '#id, #project_id' do
    FactoryBot.create(:valid_extract, project: other_project) # not this one
    q = Queries::Extract::Autocomplete.new(extract.id.to_s, project_id: Current.project_id)
    expect(q.autocomplete).to contain_exactly(extract)
  end

end
