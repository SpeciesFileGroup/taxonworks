require 'rails_helper'

describe 'AttributeAnnotations', :type => :model do
  let(:instance) { TestAttributeAnnotations.new } 
  let(:klass) { TestAttributeAnnotations } 
  let(:otu) { Otu.create(name: 'Aus') }

  context 'annotations identical to original value' do
    before {
      instance.sti = otu
      instance.string = 'name'  # the column being annotated
      instance.text = 'Aus'     # the value of the annotation
    }
    
    specify 'are not allowed' do
      instance.valid?
      expect(instance.errors.include?(:string)).to be_truthy
    end
  end

  context 'annotations on invalid columns' do
    before {
      instance.sti = otu
      instance.text = 'Aus'              # the value of the annotation
    }

    specify 'ending in _id are not allowed' do
      instance.string = 'taxon_name_id'  # the column being annotated
      instance.valid?
      expect(instance.errors.include?(:string)).to be_truthy
    end
  end

  context "instance methods" do
    before {
      instance.sti = otu
      instance.string = 'name'  # the column being annotated
      instance.text = 'Bus'     # the value of the annotation
    }

    specify "#annotated_column" do
      expect(instance.annotated_column).to eq('name')
    end

    specify "#annotation_value" do
      expect(instance.annotation_value).to eq('Bus')
    end

    specify "#original_value" do
      expect(instance.original_value).to eq('Aus')
    end
  end

end

class TestAttributeAnnotations< ActiveRecord::Base
  include FakeTable
  include Shared::AttributeAnnotations

  belongs_to :sti, polymorphic: true

  def annotated_object
    sti 
  end

  def self.annotated_attribute_column
    :string
  end

  def self.annotation_value_column
    :text
  end 

end


