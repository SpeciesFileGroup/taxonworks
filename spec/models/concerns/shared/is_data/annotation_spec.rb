require 'rails_helper'

describe 'Annotation', type: :model do

  let(:test_is_data_annotation_instance) { TestIsDataAnnotation.new }
  let(:test_is_data_annotation_subclass_instance) { TestIsDataAnnotationSubclass.new }

  ::ANNOTATION_TYPES.each do |t|
    specify "#has_#{t}?" do
      expect(test_is_data_annotation_instance.send("has_#{t}?")).to eq(false)
    end
  
    specify ".has_#{t}?" do
      expect(TestIsDataAnnotation.send("has_#{t}?")).to eq(false)
    end
  end

  specify '#has_<tags>?' do
    expect(TestIsDataAnnotationSubclass.new.has_tags?).to eq(true)
  end

  specify '.has_<tags>?' do
    expect(TestIsDataAnnotationSubclass.has_tags?).to eq(true)
  end

  specify '#available_annotations_types 1' do
    expect(test_is_data_annotation_instance.available_annotation_types).to contain_exactly() 
  end

  specify '#available_annotations_types 2' do
    expect(test_is_data_annotation_subclass_instance.available_annotation_types).to contain_exactly(:tags) 
  end

  specify '#available_annotation_types' do
    expect(test_is_data_annotation_instance.available_annotation_types).to contain_exactly()
  end 

  specify '#available_annotation_types' do
    expect(test_is_data_annotation_subclass_instance.available_annotation_types).to contain_exactly(:tags)
  end 

  specify '#annotation_metadata' do
    expect(test_is_data_annotation_subclass_instance.annotation_metadata).to eq({tags: {total: 0}})
  end

end

class TestIsDataAnnotation < ApplicationRecord
  include FakeTable
  include Shared::IsData::Annotation
end

class TestIsDataAnnotationSubclass < TestIsDataAnnotation
  include Shared::Tags
end

