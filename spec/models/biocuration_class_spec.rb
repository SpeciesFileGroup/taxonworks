require 'rails_helper'

describe BiocurationClass, type: :model do

  let(:biocuration_class) {BiocurationClass.new}

  context 'associations' do
    context 'has_many' do
      specify 'biocuration_classifications' do
        expect(biocuration_class.biocuration_classifications << FactoryBot.build(:valid_biocuration_classification)).to be_truthy
      end

      specify 'collection_objects' do
        expect(biocuration_class.collection_objects << FactoryBot.build(:valid_specimen)).to be_truthy
      end

      specify 'field_occurrences' do
        expect(biocuration_class.field_occurrences << FactoryBot.build(:valid_field_occurrence)).to be_truthy
      end

      specify 'tags' do
        expect(biocuration_class.tags << FactoryBot.build(:valid_tag)).to be_truthy
      end
    end
  end

  context 'concerns' do
    it_behaves_like 'taggable'
  end

end
