require 'rails_helper'

RSpec.describe DerivedCollectionObject, type: :model, group: :collection_objects do

let(:derived_collection_object) { DerivedCollectionObject.new }

  context 'validation' do 
    before {derived_collection_object.valid?}
    
    specify 'collection_object is required' do
      expect(derived_collection_object.errors.include?(:collection_object_id)).to be_truthy
    end 

    specify 'observed_collection_object is required' do
      expect(derived_collection_object.errors.include?(:collection_object_observation_id)).to be_truthy
    end 

  end


end
