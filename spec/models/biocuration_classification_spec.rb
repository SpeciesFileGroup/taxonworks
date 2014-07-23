require 'rails_helper'

describe BiocurationClassification, :type => :model do
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
      expect(biocuration_classification.errors.include?(:biological_collection_object)).to be_truthy
    end

    specify 'biocuration_class is required' do
      expect(biocuration_classification.errors.include?(:biocuration_class)).to be_truthy
    end

    context 'with a biocuration class' do
      before(:each) {
        biocuration_classification.biocuration_class = FactoryGirl.create(:valid_biocuration_class)
      }

      specify 'a specimen can be biocuration classified' do
        biocuration_classification.biological_collection_object = FactoryGirl.create(:valid_specimen)
        expect(biocuration_classification.save).to be_truthy
      end

      specify 'a lot can be biocuration classified' do
        biocuration_classification.biological_collection_object = FactoryGirl.create(:valid_lot)
        expect(biocuration_classification.save).to be_truthy
      end

      specify 'a ranged_lot can be biocuration classified' do
        biocuration_classification.biological_collection_object = FactoryGirl.create(:valid_ranged_lot)
        expect(biocuration_classification.save).to be_truthy
      end


    end
  end

end
