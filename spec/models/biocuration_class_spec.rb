require 'spec_helper'

describe BiocurationClass do

  let(:biocuration_class) {BiocurationClass.new}

  context 'associations' do
    context 'has_many' do
      specify 'biocuration_classifications' do
        expect(biocuration_class).to respond_to(:biocuration_classifications)
      end

      specify 'biological_objects' do
        expect(biocuration_class).to respond_to(:biological_objects)
      end
    end
  end

  context 'validations' do
    before(:each) do
      biocuration_class.valid?
    end
    specify 'name is required' do
      expect(biocuration_class.errors.include?(:name)).to be_true
    end
  end

end
