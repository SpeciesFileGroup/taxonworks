require 'spec_helper'

describe Identifier do

  let(:s) { Identifier.new }
  

  specify 'it should be identifiable' do
    expect(s).to respond_to(:identifiable)
    expect(s.identifiable).to be(nil)   
  end

  context "validation" do 
    specify 'identifier can not be nil' do
      s.save
      expect(s.errors.include?(:identifier)).to be_true
     end

    specify 'identifiable_id can not be nil' do
      s.save
      expect(s.errors.include?(:identifiable_id)).to be_true
     end

    specify 'identifiable_type can not be nil' do
      s.save
      expect(s.errors.include?(:identifiable_type)).to be_true
    end

    specify "type can not be nil" do
      s.save
      expect(s.errors.include?(:type)).to be_true
    end

  end

end


