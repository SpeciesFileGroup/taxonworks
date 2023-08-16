require 'rails_helper'

describe Queries::Descriptor::Filter, type: :model, group: [:observation_matrix] do

  let(:q) { Queries::Descriptor::Filter.new({}) }

  let(:d1) { Descriptor::Continuous.create!(name: 'Abc 1') }
  let(:d2) { Descriptor::Working.create!(name: 'Def 2') }

  specify '#term' do 
    q.term = 'Abc'
    expect(q.all).to contain_exactly(d1)
  end

end
