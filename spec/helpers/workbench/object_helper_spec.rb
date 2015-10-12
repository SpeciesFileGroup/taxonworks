require 'rails_helper'

describe Workbench::ObjectHelper, type: :helper do

  let(:specimen) {FactoryGirl.create(:valid_specimen) } 
  let(:internal_attribute) {FactoryGirl.create(:valid_data_attribute_internal_attribute) } 
  let(:biological_collection_object) { CollectionObject::BiologicalCollectionObject.create(total: 1) } 

  # Internal attribute has its own method
  specify '#object_tag_method references a method for a subclassed object that has its own _tag method' do
    expect(helper.object_tag_method(internal_attribute)).to eq('internal_attribute_tag')
  end

  # Specimen does not
  specify '#object_tag_method references base classed method for a subclassed object that does not have its own _tag method' do
    expect(helper.object_tag_method(specimen)).to eq('collection_object_tag')
  end

end
