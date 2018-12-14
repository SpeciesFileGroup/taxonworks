require 'rails_helper'

RSpec.describe Observation, type: :model, group: :matrix do
  let(:observation) { Observation.new } 
  
  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:collection_object) { FactoryBot.create(:valid_collection_object) }
  let(:descriptor) { FactoryBot.create(:valid_descriptor) }

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

  specify '#observation_object_global_id' do
    observation.observation_object_global_id = collection_object.to_global_id.to_s
    expect(observation.observation_object_global_id).to eq(collection_object.to_global_id.to_s) 
  end

  specify 'new() initializes row object via observation_object_global_id' do
    o = Observation.new(observation_object_global_id: otu.to_global_id.to_s)
    expect(o.otu_id).to eq(otu.id)
  end

  context '.copy' do
    let(:old) { FactoryBot.create(:valid_otu) }
    let(:new) { FactoryBot.create(:valid_otu) }

    let!(:o1) { FactoryBot.create(:valid_observation, otu: old) } 

    specify 'copies between objects' do
      Observation.copy(old.to_global_id.to_s, new.to_global_id.to_s)
      expect(new.observations.count).to eq(1)
    end

    specify 'does not fail on duplicates' do
      o = FactoryBot.create(:valid_observation, otu: new, descriptor: o1.descriptor) 
      expect(Observation.copy(old.to_global_id.to_s, new.to_global_id.to_s)).to be_truthy
    end

  end

  # TODO: move to Observation::Working when ready
  specify '#description is not trimmed' do
    s = " asdf sd  \n  asdfd \r\n" 
    observation.description = s
    observation.valid?
    expect(observation.description).to eq(s)
  end


end
