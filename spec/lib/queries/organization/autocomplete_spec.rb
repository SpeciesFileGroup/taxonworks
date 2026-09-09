require 'rails_helper'

describe Queries::Organization::Autocomplete, type: :model, group: :organizations do

  let!(:o1) { Organization.create!(name: 'Natural History Museum') }
  let!(:o2) { Organization.create!(name: 'Field Museum', legal_name: 'The Field Museum of Natural History') }
  let!(:o3) { Organization.create!(name: 'Smithsonian', alternate_name: 'SI') }

  let(:query) { Queries::Organization::Autocomplete.new('') }

  specify 'blank query returns nothing' do
    expect(query.autocomplete).to eq([])
  end

  specify 'exact id' do
    query.query_string = o2.id.to_s
    expect(query.autocomplete.map(&:id)).to include(o2.id)
  end

  specify 'exact name' do
    query.query_string = 'Field Museum'
    expect(query.autocomplete.map(&:id)).to contain_exactly(o2.id)
  end

  specify 'exact legal_name' do
    query.query_string = 'The Field Museum of Natural History'
    expect(query.autocomplete.map(&:id)).to contain_exactly(o2.id)
  end

  specify 'exact alternate_name' do
    query.query_string = 'SI'
    expect(query.autocomplete.map(&:id)).to contain_exactly(o3.id)
  end

  specify 'name starts with' do
    query.query_string = 'Smithson'
    expect(query.autocomplete.map(&:id)).to contain_exactly(o3.id)
  end

  specify 'ordered wildcard pieces across name and legal_name' do
    query.query_string = 'field nat hist'
    expect(query.autocomplete.map(&:id)).to contain_exactly(o2.id)
  end

  specify 'unordered fragments in name' do
    query.query_string = 'history natural'
    expect(query.autocomplete.map(&:id)).to contain_exactly(o1.id)
  end

  specify 'geographic area name' do
    ga = FactoryBot.create(:valid_geographic_area, name: 'Freedonia')
    o2.update!(geographic_area: ga)
    query.query_string = 'freedonia'
    expect(query.autocomplete.map(&:id)).to contain_exactly(o2.id)
  end

  specify 'exact identifier (cached)' do
    Identifier::Global::Uri.create!(identifier_object: o1, identifier: 'https://ror.org/example123')
    query.query_string = 'https://ror.org/example123'
    expect(query.autocomplete.map(&:id)).to contain_exactly(o1.id)
  end

  specify 'no role_type accessor remains' do
    expect(query).not_to respond_to(:role_type)
  end
end
