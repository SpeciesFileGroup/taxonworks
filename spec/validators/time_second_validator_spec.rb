require 'rails_helper'

RSpec.describe TimeSecondValidator, type: :validator, group: :validator do
  context 'validations' do
    context 'no parameters given for validator' do
      let(:test_model) {
        time_second_validator_class(true).new
      }

      specify 'empty second is valid' do
        expect(test_model.valid?).to be_truthy
      end

      specify 'default min second is 0' do
        test_model.second = -1
        expect(test_model.valid?).to be_falsey

        test_model.second = 0
        expect(test_model.valid?).to be_truthy
      end

      specify 'default max second is 59' do
        test_model.second = 60
        expect(test_model.valid?).to be_falsey

        test_model.second = 59
        expect(test_model.valid?).to be_truthy
      end
    end 

    context 'parameters given for validator' do
      context 'min_second' do
        let(:test_model) {
          time_second_validator_class({ min_second: 2 }).new
        }

        specify 'min_second now 2' do
          test_model.second = 1
          expect(test_model.valid?).to be_falsey

          test_model.second = 2
          expect(test_model.valid?).to be_truthy
        end

        specify 'max_second still 59' do
          test_model.second = 60
          expect(test_model.valid?).to be_falsey

          test_model.second = 59
          expect(test_model.valid?).to be_truthy
        end
      end

      context 'max_second' do
        let(:test_model) {
          time_second_validator_class({ max_second: 2000 }).new
        }

        specify 'max_second now 2000' do
          test_model.second = 2000
          expect(test_model.valid?).to be_truthy

          test_model.second = 2001
          expect(test_model.valid?).to be_falsey
        end

        specify 'min_second still 0' do
          test_model.second = -1
          expect(test_model.valid?).to be_falsey

          test_model.second = 0
          expect(test_model.valid?).to be_truthy
        end
      end
    end
  end
end

def time_second_validator_class(options)
  Class.new(ValidatorsHelper::ValidationTester) do
    attr_accessor :second

    validates :second, time_second: options
  end
end