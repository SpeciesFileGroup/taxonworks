require 'rails_helper'

describe BiocurationClassification, type: :model do
  let(:biocuration_classification) {BiocurationClassification.new}
  let(:biocuration_class) { FactoryBot.create(:valid_biocuration_class) }
  let(:specimen) { FactoryBot.create(:valid_specimen) }

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

    specify '#biological_collection_object is required' do
      expect(biocuration_classification.errors.include?(:biological_collection_object)).to be_truthy
    end

    specify '#biocuration_class is required' do
      expect(biocuration_classification.errors.include?(:biocuration_class)).to be_truthy
    end

    specify '#biocuration_class built through paramss' do
      biocuration_classification.biocuration_class_id = biocuration_class.id
      biocuration_classification.biocuration_classification_object_id = specimen.id
      biocuration_classification.biocuration_classification_object_type = 'CollectionObject'
      expect(biocuration_classification.save!).to be_truthy
    end

    context 'with a biocuration class' do
      before(:each) {
        biocuration_classification.biocuration_class = biocuration_class
      }

      specify 'a specimen can be biocuration classified' do
        biocuration_classification.biological_collection_object = FactoryBot.create(:valid_specimen)
        expect(biocuration_classification.save).to be_truthy
      end

      specify 'a lot can be biocuration classified' do
        biocuration_classification.biological_collection_object = FactoryBot.create(:valid_lot)
        expect(biocuration_classification.save).to be_truthy
      end

      specify 'a ranged_lot can be biocuration classified' do
        biocuration_classification.biological_collection_object = FactoryBot.create(:valid_ranged_lot)
        expect(biocuration_classification.save).to be_truthy
      end
    end

    context 'class per object' do
      before do
        BiocurationClassification.create!(biocuration_class:, biological_collection_object: specimen)
      end

      specify 'can not be duplicated' do
        expect(BiocurationClassification.create(biocuration_class:, biological_collection_object: specimen).id).to eq(nil)
      end
    end

  end

  context 'concerns' do
    it_behaves_like 'is_data'
  end

end
