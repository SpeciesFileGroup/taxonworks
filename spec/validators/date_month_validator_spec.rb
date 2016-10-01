require 'rails_helper'

RSpec.describe DateMonthValidator, type: :validator, group: :validator do
  context 'validations' do
    context 'no parameters given for validator' do
      let(:test_model) {
        date_month_validator_class(true).new
      }

      specify 'empty month is valid' do
        expect(test_model.valid?).to be_truthy
      end

      specify 'default min month is 1' do
        test_model.month = 0
        expect(test_model.valid?).to be_falsey

        test_model.month = 1
        expect(test_model.valid?).to be_truthy
      end

      specify 'default max month is 12' do
        test_model.month = 13
        expect(test_model.valid?).to be_falsey

        test_model.month = 12
        expect(test_model.valid?).to be_truthy
      end
    end 

    context 'parameters given for validator' do
      context 'min_month' do
        let(:test_model) {
          date_month_validator_class({ min_month: 2 }).new
        }

        specify 'min_month now 2' do
          test_model.month = 1
          expect(test_model.valid?).to be_falsey

          test_model.month = 2
          expect(test_model.valid?).to be_truthy
        end

        specify 'max_month still 12' do
          test_model.month = 13
          expect(test_model.valid?).to be_falsey

          test_model.month = 12
          expect(test_model.valid?).to be_truthy
        end
      end

      context 'max_month' do
        let(:test_model) {
          date_month_validator_class({ max_month: 20 }).new
        }

        specify 'max_month now 20' do
          test_model.month = 20
          expect(test_model.valid?).to be_truthy

          test_model.month = 21
          expect(test_model.valid?).to be_falsey
        end

        specify 'min_month still 1' do
          test_model.month = 0
          expect(test_model.valid?).to be_falsey

          test_model.month = 1
          expect(test_model.valid?).to be_truthy
        end
      end
    end
  end
end

def date_month_validator_class(options)
  Class.new(ValidatorsHelper::ValidationTester) do
    attr_accessor :month

    validates :month, date_month: options
  end
end