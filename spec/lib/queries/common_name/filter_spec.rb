require 'rails_helper'

describe Queries::CommonName::Filter, type: :model do

  let(:otu) { FactoryBot.create(:valid_otu) }

  let!(:cn1) { CommonName.create!(name: 'Flat grass scale', otu: otu) }
  let!(:cn2) { CommonName.create!(name: 'Grass hopper', otu: otu) }
  let!(:cn3) { CommonName.create!(name: 'Red ant', otu: otu) }

  let(:query) { Queries::CommonName::Filter.new({}) }

  specify '#name with name_exact: true returns only exact matches' do
    query.name = 'Flat grass scale'
    query.name_exact = true
    expect(query.all.map(&:id)).to contain_exactly(cn1.id)
  end

  specify '#name with name_exact: true does not return partial matches' do
    query.name = 'grass'
    query.name_exact = true
    expect(query.all.map(&:id)).to eq([])
  end

  specify '#name with name_exact: false returns fuzzy matches' do
    query.name = 'grass'
    query.name_exact = false
    expect(query.all.map(&:id)).to contain_exactly(cn1.id, cn2.id)
  end

  specify '#name without name_exact defaults to fuzzy matching' do
    query.name = 'grass'
    expect(query.all.map(&:id)).to contain_exactly(cn1.id, cn2.id)
  end

end
