require 'spec_helper'

describe Specimen do
  let(:specimen) { Specimen.new }

  context "validation" do
    before(:each) do 
      specimen.valid?
    end

    specify 'valid_specimen is valid' do
      s = FactoryGirl.build(:valid_specimen)
      expect(s.creator == s.updater).to be_true
      expect(s.project).to be_true
      expect(s.save).to be_true
    end

    specify "total must be one" do 
      expect(specimen.total).to eq(1)
    end
  end

  context "concerns" do
    it_behaves_like "containable"
    it_behaves_like "identifiable"
    it_behaves_like "determinable"
  end

end


