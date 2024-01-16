require 'rails_helper'

describe BiocurationClass, type: :model do

  let(:biocuration_class) {BiocurationClass.new}

  context 'associations' do
    context 'has_many' do
      specify 'biocuration_classifications' do
        expect(biocuration_class.biocuration_classifications << FactoryBot.build(:valid_biocuration_classification)).to be_truthy
      end

      specify 'biological instances' do
        expect(biocuration_class.biocuration_classification_objects << FactoryBot.build(:valid_specimen)).to be_truthy
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
