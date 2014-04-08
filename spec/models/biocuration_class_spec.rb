require 'spec_helper'

describe BiocurationClass do

  let(:biocuration_class) {BiocurationClass.new}

  context 'associations' do
    context 'has_many' do
      specify 'biocuration_classifications' do
        expect(biocuration_class.biocuration_classifications << FactoryGirl.build(:valid_biocuration_classification)).to be_true
      end

      specify 'biological_objects' do
        expect(biocuration_class.biological_collection_objects << FactoryGirl.build(:valid_specimen)).to be_true
      end

      specify 'tags' do
        expect(biocuration_class.tags << FactoryGirl.build(:valid_tag)).to be_true
      end
    end
  end

end
