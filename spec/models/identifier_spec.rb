require 'spec_helper'

describe Identifier do

  let(:identifier) { Identifier.new }

  specify 'has an identified_object' do
    expect(identifier).to respond_to(:identified_object)
    expect(identifier.identified_object).to be(nil)   
  end

  context 'validation' do
    context 'requires' do
      before do
        identifier.save
      end
      
      specify 'identifier' do
        expect(identifier.errors.include?(:identifier)).to be_true
      end

      specify 'identified_object_id' do
        expect(identifier.errors.include?(:identified_object_id)).to be_true
      end

      specify 'identified_object_type' do
        expect(identifier.errors.include?(:identified_object_type)).to be_true
      end

      specify 'type' do
        expect(identifier.errors.include?(:type)).to be_true
      end
    end
  end

  context 'beth\'s todo tests' do
   pending 'test scoping :of_type  using different identifiers on a single object'
    # src.of_type(:isbn) should return one and only one identifier
   pending 'test that you can\'t add multiple identifiers of the same type to a single object'
    # e.g. two ISBN to a single source should not be allowed

  end


end


