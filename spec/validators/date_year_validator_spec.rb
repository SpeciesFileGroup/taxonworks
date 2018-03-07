require 'rails_helper'

RSpec.describe DateYearValidator, type: :validator, group: :validator do
  context 'validations' do
    context 'no parameters given for validator' do
      let(:test_model) {
        date_year_validator_class(true).new
      }

      specify 'empty year is valid' do
        expect(test_model.valid?).to be_truthy
      end

      specify 'default min year is 1000' do
        test_model.year = 999
        expect(test_model.valid?).to be_falsey

        test_model.year = 1000
        expect(test_model.valid?).to be_truthy
      end

      specify 'default max year is Time.now.year + 5' do
        test_model.year = Time.now.year + 6
        expect(test_model.valid?).to be_falsey

        test_model.year = Time.now.year + 5
        expect(test_model.valid?).to be_truthy
      end
    end 

    context 'parameters given for validator' do
      context 'min_year' do
        let(:test_model) {
          date_year_validator_class({ min_year: 2 }).new
        }

        specify 'min_year now 2' do
          test_model.year = 1
          expect(test_model.valid?).to be_falsey

          test_model.year = 2
          expect(test_model.valid?).to be_truthy
        end

        specify 'max_year still 12' do
          test_model.year = Time.now.year + 6
          expect(test_model.valid?).to be_falsey

          test_model.year = Time.now.year + 5
          expect(test_model.valid?).to be_truthy
        end
      end

      context 'max_year' do
        let(:test_model) {
          date_year_validator_class({ max_year: 2000 }).new
        }

        specify 'max_year now 2000' do
          test_model.year = 2000
          expect(test_model.valid?).to be_truthy

          test_model.year = 2001
          expect(test_model.valid?).to be_falsey
        end

        specify 'min_year still 1000' do
          test_model.year = 999
          expect(test_model.valid?).to be_falsey

          test_model.year = 1000
          expect(test_model.valid?).to be_truthy
        end
      end
    end
  end
end

def date_year_validator_class(options)
  Class.new(ValidatorsHelper::ValidationTester) do
    attr_accessor :year

    validates :year, date_year: options
  end
end