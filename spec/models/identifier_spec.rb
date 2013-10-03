require 'spec_helper'

describe Identifier do

  let(:identifier) { Identifier.new }

  # TODO: clarify polymorphic status in tests
  specify 'it should be identifiable' do
    expect(identifier).to respond_to(:identifiable)
    expect(identifier.identifiable).to be(nil)   
  end

  context "validation" do 
    context "requires" do
      before do
        identifier.save
      end
      
      specify 'identifier' do
        expect(identifier.errors.include?(:identifier)).to be_true
      end

      specify 'identifiable_id' do
        expect(identifier.errors.include?(:identifiable_id)).to be_true
      end

      specify 'identifiable_type' do
        expect(identifier.errors.include?(:identifiable_type)).to be_true
      end

      specify "type" do
        expect(identifier.errors.include?(:typification)).to be_true
      end
    end
  end

end


