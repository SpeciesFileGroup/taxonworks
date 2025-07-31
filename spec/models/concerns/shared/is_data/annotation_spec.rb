require 'rails_helper'

describe 'Annotation', type: :model do

  let(:test_is_data_annotation_instance) { TestIsDataAnnotation.new }
  let(:test_is_data_annotation_subclass_instance) { TestIsDataAnnotationSubclass.new }

  specify '#move_annotations - only' do
    a = FactoryBot.create(:valid_otu)
    b = FactoryBot.create(:valid_otu)

    FactoryBot.create(:valid_citation, citation_object: a)
    FactoryBot.create(:valid_data_attribute, attribute_subject: a)

    a.move_annotations(to_object: b, only: [:data_attributes])
    expect(b.citations.count).to eq(0)
    expect(b.data_attributes.count).to eq(1)
  end

  specify '#move_annotations except' do
    a = FactoryBot.create(:valid_otu)
    b = FactoryBot.create(:valid_otu)

    c = FactoryBot.create(:valid_citation, citation_object: a)

    a.move_annotations(to_object: b, except: [:citations])

    expect(a.citations.count).to eq(1)
    expect(b.citations.count).to eq(0)
  end

  specify '#move_annotations - citations' do
    a = FactoryBot.create(:valid_otu)
    b = FactoryBot.create(:valid_otu)

    c = FactoryBot.create(:valid_citation, citation_object: a)

    a.move_annotations(to_object: b)

    expect(a.citations.count).to eq(0)
    expect(b.citations.count).to eq(1)
  end

  specify '#clone_annotations - citations' do
    a = FactoryBot.create(:valid_otu)
    b = FactoryBot.create(:valid_otu)

    c = FactoryBot.create(:valid_citation, citation_object: a)

    a.clone_annotations(to_object: b)
    expect(b.citations.count).to eq(1)
  end

  specify '#clone_annotations - except' do
    a = FactoryBot.create(:valid_otu)
    b = FactoryBot.create(:valid_otu)

    c = FactoryBot.create(:valid_citation, citation_object: a)

    a.clone_annotations(to_object: b, except: [:citations])
    expect(b.citations.count).to eq(0)
  end

  specify '#clone_annotations - only' do
    a = FactoryBot.create(:valid_otu)
    b = FactoryBot.create(:valid_otu)

    FactoryBot.create(:valid_citation, citation_object: a)
    FactoryBot.create(:valid_data_attribute, attribute_subject: a)

    a.clone_annotations(to_object: b, only: [:data_attributes])
    expect(b.citations.count).to eq(0)
    expect(b.data_attributes.count).to eq(1)
  end

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

