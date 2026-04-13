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

end
