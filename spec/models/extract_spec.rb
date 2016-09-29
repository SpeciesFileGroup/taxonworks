require 'rails_helper'

RSpec.describe Extract, type: :model, group: :extract do

  context 'validations' do
    context 'fails when not given' do
      let(:empty_extract) {
        Extract.new
      }

      before(:each){
        empty_extract.valid?
      }

      specify 'quantity_value' do
        expect(empty_extract.errors.include?(:quantity_value)).to be_truthy
      end

      specify 'quantity_unit' do
        expect(empty_extract.errors.include?(:quantity_unit)).to be_truthy
      end

      specify 'verbatim_anatomical_origin' do
        expect(empty_extract.errors.include?(:verbatim_anatomical_origin)).to be_truthy
      end

      specify 'year_made' do
        expect(empty_extract.errors.include?(:year_made)).to be_truthy
      end

      specify 'month_made' do
        expect(empty_extract.errors.include?(:month_made)).to be_truthy
      end

      specify 'day_made' do
        expect(empty_extract.errors.include?(:day_made)).to be_truthy
      end
    end

    
    context 'fails when given invalid dates' do
      let(:valid_extract){
        FactoryGirl.build(:valid_extract)
      }

      after(:each){
        expect(valid_extract.valid?).to be_falsey
      }

      context 'year_made' do
        specify '< 1000' do 
          valid_extract.year_made = 999
        end

        specify '> Time.now.year + 5' do 
          valid_extract.year_made = Time.now.year + 6
        end
      end

      context 'month_made' do
        specify '< 1' do
          valid_extract.month_made = 0
        end

        specify '> 12' do
          valid_extract.month_made = 13
        end
      end

      context 'day_made' do
        specify '< 1' do
          valid_extract.day_made = 0
        end

        specify '> 31' do
          valid_extract.day_made = 32
        end
      end
    end

    context 'passes when given' do
      specify 'quantity_value and quantity_unit and concentration_value and concentration_unit and verbatim_anatomical_origin and year_made and month_made and day_made' do
        expect(FactoryGirl.build(:valid_extract).valid?).to be_truthy
      end
    end
  end
end
