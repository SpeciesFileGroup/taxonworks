require 'rails_helper'

RSpec.describe Extract, type: :model do
  let(:extract) {Extract.new}

  context 'validations' do
    context 'fails when not given' do
      before(:each){
        extract.valid?
      }

      specify 'quantity_value' do
        expect(extract.errors.include?(:quantity_value)).to be_truthy
      end

      specify 'quantity_unit' do
        expect(extract.errors.include?(:quantity_unit)).to be_truthy
      end

      specify 'quantity_concentration' do
        expect(extract.errors.include?(:quantity_concentration)).to be_truthy
      end

      specify 'verbatim_anatomical_origin' do
        expect(extract.errors.include?(:verbatim_anatomical_origin)).to be_truthy
      end

      specify 'year_made' do
        expect(extract.errors.include?(:year_made)).to be_truthy
      end

      specify 'month_made' do
        expect(extract.errors.include?(:month_made)).to be_truthy
      end

      specify 'day_made' do
        expect(extract.errors.include?(:day_made)).to be_truthy
      end
    end

    context 'passes when given' do
      specify 'quantity_value and quantity_unit and quantity_concentration and verbatim_anatomical_origin and year_made and month_made and day_made' do
        expect(FactoryGirl.build(:valid_extract).valid?).to be_truthy
      end
    end
  end
end
