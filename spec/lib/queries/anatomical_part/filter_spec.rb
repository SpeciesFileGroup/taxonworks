require 'rails_helper'

describe Queries::AnatomicalPart::Filter, type: :model do

  let(:q) { Queries::AnatomicalPart::Filter.new({}) }

  specify 'is_material == true counts as "yes, is material"' do
    FactoryBot.create(:valid_anatomical_part, is_material: true)
    q.is_material = true

    expect(q.all.count).to eq(1)
  end

  specify 'is_material == nil (on the model, not the filter) counts as "yes, is material"' do
    FactoryBot.create(:valid_anatomical_part, is_material: nil)
    q.is_material = true

    expect(q.all.count).to eq(1)
  end

  context 'sort param' do
    let!(:ap_a) { FactoryBot.create(:valid_anatomical_part, name: 'Alpha part') }
    let!(:ap_z) { FactoryBot.create(:valid_anatomical_part, name: 'Zeta part') }

    def sorted_ids(sort_key)
      Queries::AnatomicalPart::Filter.new(sort: sort_key)
        .all.where(id: [ap_a.id, ap_z.id]).pluck(:id)
    end

    specify 'sort=name orders alphabetically' do
      expect(sorted_ids('name')).to eq([ap_a.id, ap_z.id])
    end

    specify 'sort=-name reverses order' do
      expect(sorted_ids('-name')).to eq([ap_z.id, ap_a.id])
    end

    specify 'unknown sort key ignored' do
      expect(sorted_ids('no_such_column')).to contain_exactly(ap_a.id, ap_z.id)
    end
  end

end
