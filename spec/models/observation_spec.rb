require 'rails_helper'

RSpec.describe Observation, type: :model, group: :observation_matrix do
  let(:observation) { Observation.new } 
  
  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:collection_object) { FactoryBot.create(:valid_collection_object) }
  let(:descriptor) { FactoryBot.create(:valid_descriptor) }

  context 'validation' do
    before { observation.valid? }

    specify '#description required' do
      expect(observation.errors.include?(:descriptor_id)).to be_truthy
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

  context 'destroy' do

    let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }
    let!(:o) { FactoryBot.create(:valid_observation, otu: otu) }
    let!(:o1) { FactoryBot.create(:valid_observation, otu: otu) } # does not use same dd
    let(:d) { o.descriptor }
    let!(:c) { FactoryBot.create(:valid_observation_matrix_column, observation_matrix: observation_matrix, descriptor: d ) }
    let!(:r) { FactoryBot.create(:valid_observation_matrix_row, observation_matrix: observation_matrix, otu: otu) }
    let!(:r1) { FactoryBot.create(:valid_observation_matrix_row, observation_matrix: observation_matrix) }

    specify '.destroy_row 1' do
      expect(Observation.destroy_row(r.id)).to be_truthy
    end

    specify '.destroy_row 2' do
      Observation.destroy_row(r1.id)
      expect(Observation.all.map(&:id)).to contain_exactly(o1.id, o.id)
    end

    specify '.destroy_row 3' do
      Observation.destroy_row(r.id)
      expect(Observation.all.map(&:id)).to contain_exactly(o1.id)
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
