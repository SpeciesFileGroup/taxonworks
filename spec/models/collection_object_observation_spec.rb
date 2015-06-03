require 'rails_helper'

RSpec.describe CollectionObjectObservation, type: :model, group: :collection_objects do

  let(:collection_object_observation) { CollectionObjectObservation.new }

  context 'validation' do 
    before {collection_object_observation.valid?}
    
    specify 'data is required' do
      expect(collection_object_observation.errors.include?(:data)).to be_truthy
    end 

  end
end
