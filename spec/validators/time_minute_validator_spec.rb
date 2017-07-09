require 'rails_helper'

RSpec.describe TimeMinuteValidator, type: :validator, group: :validator do
  context 'validations' do
    context 'no parameters given for validator' do
      let(:test_model) {
        time_minute_validator_class(true).new
      }

      specify 'empty minute is valid' do
        expect(test_model.valid?).to be_truthy
      end

      specify 'default min minute is 0' do
        test_model.minute = -1
        expect(test_model.valid?).to be_falsey

        test_model.minute = 0
        expect(test_model.valid?).to be_truthy
      end

      specify 'default max minute is 59' do
        test_model.minute = 60
        expect(test_model.valid?).to be_falsey

        test_model.minute = 59
        expect(test_model.valid?).to be_truthy
      end
    end 

    context 'parameters given for validator' do
      context 'min_minute' do
        let(:test_model) {
          time_minute_validator_class({ min_minute: 2 }).new
        }

        specify 'min_minute now 2' do
          test_model.minute = 1
          expect(test_model.valid?).to be_falsey

          test_model.minute = 2
          expect(test_model.valid?).to be_truthy
        end

        specify 'max_minute still 59' do
          test_model.minute = 60
          expect(test_model.valid?).to be_falsey

          test_model.minute = 59
          expect(test_model.valid?).to be_truthy
        end
      end

      context 'max_minute' do
        let(:test_model) {
          time_minute_validator_class({ max_minute: 2000 }).new
        }

        specify 'max_minute now 2000' do
          test_model.minute = 2000
          expect(test_model.valid?).to be_truthy

          test_model.minute = 2001
          expect(test_model.valid?).to be_falsey
        end

        specify 'min_minute still 0' do
          test_model.minute = -1
          expect(test_model.valid?).to be_falsey

          test_model.minute = 0
          expect(test_model.valid?).to be_truthy
        end
      end
    end
  end
end

def time_minute_validator_class(options)
  Class.new(ValidatorsHelper::ValidationTester) do
    attr_accessor :minute

    validates :minute, time_minute: options
  end
end