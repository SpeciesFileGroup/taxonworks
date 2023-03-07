require 'rails_helper'

describe Queries::Observation::Filter, type: :model, group: [:observation_matrix] do

  let(:q) { Queries::Observation::Filter.new({}) }

  specify '#descriptor_id' do 
    o = FactoryBot.create(:valid_observation)
    FactoryBot.create(:valid_observation)

    q.descriptor_id = o.descriptor_id
    expect(q.all.map(&:id)).to contain_exactly(o.id)
  end

  specify '#taxon_name_id' do 
    p = FactoryBot.create(:valid_protonym)
    otu = Otu.create!(taxon_name: p)

    o = FactoryBot.create(:valid_observation, observation_object: otu)
    FactoryBot.create(:valid_observation)

    q.taxon_name_id = p.id

    expect(q.all.map(&:id)).to contain_exactly(o.id)
  end

end
