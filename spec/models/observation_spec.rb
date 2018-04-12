require 'rails_helper'

RSpec.describe Observation, type: :model, group: :matrix do
  let(:observation) { Observation.new } 
  
  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:collection_object) { FactoryBot.create(:valid_collection_object) }


  context 'validation' do
    before { observation.valid? }

    specify '#description required' do
      expect(observation.errors.include?(:descriptor)).to be_truthy
    end

    specify 'one of #otu or #collection_object is required' do
      expect(observation.errors.include?(:base)).to be_truthy
    end
  end

  specify '#observation_object_global_id=' do
    observation.observation_object_global_id = otu.to_global_id.to_s
    expect(observation.otu_id).to eq(otu.id) 
  end

  specify '#observation_object_global_id' do
    observation.observation_object_global_id = collection_object.to_global_id.to_s
    expect(observation.observation_object_global_id).to eq(collection_object.to_global_id.to_s) 
  end




end
