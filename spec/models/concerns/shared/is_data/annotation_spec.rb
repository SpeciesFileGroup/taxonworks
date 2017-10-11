require 'rails_helper'

describe 'Annotation', type: :model do

  let(:test_is_data_annotation_instance) { TestIsDataAnnotation.new }
  let(:test_is_data_annotation_subclass_instance) { TestIsDataAnnotationSubclass.new }

  specify '#has_alternate_values?' do
    expect(test_is_data_annotation_instance.has_alternate_values?).to eq(false)
  end

  specify '#has_citations?' do
    expect(test_is_data_annotation_instance.has_citations?).to eq(false)
  end

  specify '#has_data_attributes?' do
    expect(test_is_data_annotation_instance.has_data_attributes?).to eq(false)
  end

  specify '#has_identifiers?' do
    expect(test_is_data_annotation_instance.has_identifiers?).to eq(false)
  end

  specify '#has_notes?' do
    expect(test_is_data_annotation_instance.has_notes?).to eq(false)
  end

  specify '#has_tags?' do
    expect(test_is_data_annotation_instance.has_tags?).to eq(false)
  end

  specify '#has_confidences?' do
    expect(test_is_data_annotation_instance.has_confidences?).to eq(false)
  end

  specify '#has_documentation?' do
    expect(test_is_data_annotation_instance.has_documentation?).to eq(false)
  end

  specify '#has_protocols?' do
    expect(test_is_data_annotation_instance.has_protocols?).to eq(false)
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
  include Shared::Taggable
end

