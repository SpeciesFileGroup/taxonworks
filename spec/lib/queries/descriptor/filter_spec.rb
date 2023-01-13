require 'rails_helper'
require 'support/shared_contexts/shared_geo'

describe Queries::Descriptor::Filter, type: :model, group: [:geo, :collection_objects, :otus, :shared_geo] do

  let(:q) { Queries::Descriptor::Filter.new({}) }

  let(:d1) { Descriptor::Continuous.create!(name: 'Abc 1') }
  let(:d2) { Descriptor::Working.create!(name: 'Def 2') }

  specify '#term' do 
    q.term = 'Abc'
    expect(q.all).to contain_exactly(d1)
  end

end
