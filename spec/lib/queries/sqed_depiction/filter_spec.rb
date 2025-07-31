require 'rails_helper'

describe Queries::SqedDepiction::Filter, type: :model, group: [:images] do

  let(:q) { Queries::SqedDepiction::Filter.new({}) }

  specify '#collecting_event' do
    a = FactoryBot.create(:valid_sqed_depiction)
    
    FactoryBot.create(:valid_sqed_depiction, depiction: FactoryBot.build(:valid_depiction, image: FactoryBot.create(:tiny_random_image))) # not this

    a.depiction.depiction_object.update!(collecting_event: FactoryBot.create(:valid_collecting_event))

    q.base_collection_object_filter_params = {collecting_event: true} 

    expect(q.all).to contain_exactly(a)
  end

end
