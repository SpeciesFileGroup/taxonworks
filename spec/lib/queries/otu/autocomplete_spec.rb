require 'rails_helper'

describe Queries::Otu::Autocomplete, type: :model do
  let!(:otu) { Otu.create!(name: name) }
  let(:name) { 'Test' }
  let(:query) { Queries::Otu::Autocomplete.new('Test') }
  let(:other_project) { FactoryBot.create(:valid_project, name: 'other') }

  specify 'named' do
    expect(query.autocomplete).to include(otu)
  end

  specify '#project_id' do
    o = Otu.create!(project: other_project, name: name)
    q = Queries::Otu::Autocomplete.new('Test', project_id: Current.project_id)
    expect(q.autocomplete).to contain_exactly(otu)
  end

end
