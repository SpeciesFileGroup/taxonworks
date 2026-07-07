require 'rails_helper'

describe Queries::Descriptor::Filter, type: :model, group: [:observation_matrix] do

  let(:q) { Queries::Descriptor::Filter.new({}) }

  let(:d1) { Descriptor::Continuous.create!(name: 'Abc 1') }
  let(:d2) { Descriptor::Working.create!(name: 'Def 2') }

  specify '#term' do
    q.term = 'Abc'
    expect(q.all).to contain_exactly(d1)
  end

  context 'sort param' do
    let!(:d_a) { Descriptor::Continuous.create!(name: 'Alpha descriptor') }
    let!(:d_z) { Descriptor::Continuous.create!(name: 'Zeta descriptor') }

    def sorted_ids(sort_key)
      Queries::Descriptor::Filter.new(sort: sort_key)
        .all.where(id: [d_a.id, d_z.id]).pluck(:id)
    end

    specify 'sort=name orders alphabetically' do
      expect(sorted_ids('name')).to eq([d_a.id, d_z.id])
    end

    specify 'sort=-name desc' do
      expect(sorted_ids('-name')).to eq([d_z.id, d_a.id])
    end

    specify 'unknown sort key ignored' do
      expect(sorted_ids('no_such_column')).to contain_exactly(d_a.id, d_z.id)
    end
  end

end
