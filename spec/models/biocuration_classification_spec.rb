require 'spec_helper'

describe BiocurationClassification do
  let(:biocuration_classification) {BiocurationClassification.new}
  context 'associations' do
    context 'belongs_to' do
      specify 'biological_object' do
        expect(biocuration_classification).to respond_to(:biological_collection_object)
      end
      specify 'biocuration_class' do
        expect(biocuration_classification).to respond_to(:biocuration_class)
      end
    end
  end

  context 'validation' do
    before(:each) do
      biocuration_classification.valid?
    end 
    specify 'biological_collection_object is required' do
      expect(biocuration_classification.errors.include?(:biological_collection_object)).to be_true 
    end

    specify 'biocuration_class is required' do
      expect(biocuration_classification.errors.include?(:biocuration_class)).to be_true 
    end
  end

end
