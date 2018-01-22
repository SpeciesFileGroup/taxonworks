require 'rails_helper'

describe Specimen, type: :model, group: :collection_objects do
  let(:specimen) { Specimen.new }

  context 'validation' do
    before(:each) do
      specimen.valid?
    end

    specify 'valid_specimen is valid' do
      s = FactoryBot.build(:valid_specimen)
      expect(s.valid?).to be_truthy
    end

    specify '#total must be one' do
      expect(specimen.total).to eq(1)
    end
  end

  specify '#derived_extracts' do
    expect(specimen).to respond_to(:derived_extracts)
  end

  context 'concerns' do
    it_behaves_like 'containable'
    it_behaves_like 'identifiable'
  end

end

