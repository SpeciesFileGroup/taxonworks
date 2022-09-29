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

    specify '#observation_object is required' do
      expect(observation.errors.include?(:observation_object)).to be_truthy
    end
  end

  context '#code_column' do
    let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }

    let!(:d1) { Descriptor::Qualitative.new(name: 'foo') }
    let!(:cs) { CharacterState.new(label: 0, name: 'foo', descriptor: d1) }

    let!(:c1) { FactoryBot.create(:valid_observation_matrix_column, observation_matrix: observation_matrix, descriptor: d1 ) }
    let!(:r1) { FactoryBot.create(:valid_observation_matrix_row, observation_matrix: observation_matrix, observation_object: otu) }
    let!(:r2) { FactoryBot.create(:valid_observation_matrix_row, observation_matrix: observation_matrix) }

    specify '#code_column 1' do 
      p = {character_state: cs} 
      Observation.code_column(c1.id, p)

      expect(Observation.all.count).to eq(2)
    end

    specify '#code_column 2' do 
      p = {character_state: cs} 
      Observation.code_column(c1.id, p)

      expect(r2.observation_object.observations.count).to eq(1)
    end

  end


  xspecify '#time_made 1' do
    observation.time_made = '12:99:12'
    observation.valid?
    expect(observation.errors.include?(:time_made)).to be_truthy
  end

  xspecify '#time_made 2' do
    observation.time_made = '12:00:12'
    observation.valid?
    expect(observation.errors.include?(:time_made)).to be_falsey
  end

  specify '#observation_object_global_id=' do
    observation.observation_object_global_id = otu.to_global_id.to_s
    expect(observation.observation_object).to eq(otu) 
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
    expect(o.observation_object).to eq(otu)
  end

  context '.copy' do
    let(:old) { FactoryBot.create(:valid_otu) }
    let(:new) { FactoryBot.create(:valid_otu) }

    let!(:o1) { FactoryBot.create(:valid_observation, observation_object: old) } 

    specify '.copy between objects' do
      Observation.copy(old.to_global_id.to_s, new.to_global_id.to_s)
      expect(new.observations.count).to eq(1)
    end

    specify 'also copies depictions' do
      o1.depictions << FactoryBot.build(:valid_depiction)
      Observation.copy(old.to_global_id.to_s, new.to_global_id.to_s)
      expect(new.observations.first.depictions.count).to eq(1)
    end

    specify 'does not fail on duplicates' do
      o = FactoryBot.create(:valid_observation, observation_object: new, descriptor: o1.descriptor) 
      expect(Observation.copy(old.to_global_id.to_s, new.to_global_id.to_s)).to be_truthy
    end
  end

  context 'destroy' do
    let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }
    let!(:o) { FactoryBot.create(:valid_observation, observation_object: otu) }
    let!(:o1) { FactoryBot.create(:valid_observation, observation_object: otu) } # does not use same dd
    let(:d) { o.descriptor }
    let!(:c) { FactoryBot.create(:valid_observation_matrix_column, observation_matrix: observation_matrix, descriptor: d ) }
    let!(:r) { FactoryBot.create(:valid_observation_matrix_row, observation_matrix: observation_matrix, observation_object: otu) }
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
