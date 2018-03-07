require 'rails_helper'

RSpec.describe TimeHourValidator, type: :validator, group: :validator do
  context 'validations' do
    context 'no parameters given for validator' do
      let(:test_model) {
        time_hour_validator_class(true).new
      }

      specify 'empty hour is valid' do
        expect(test_model.valid?).to be_truthy
      end

      specify 'default min hour is 0' do
        test_model.hour = -1
        expect(test_model.valid?).to be_falsey

        test_model.hour = 0
        expect(test_model.valid?).to be_truthy
      end

      specify 'default max hour is 23' do
        test_model.hour = 24
        expect(test_model.valid?).to be_falsey

        test_model.hour = 23
        expect(test_model.valid?).to be_truthy
      end
    end 

    context 'parameters given for validator' do
      context 'min_hour' do
        let(:test_model) {
          time_hour_validator_class({ min_hour: 2 }).new
        }

        specify 'min_hour now 2' do
          test_model.hour = 1
          expect(test_model.valid?).to be_falsey

          test_model.hour = 2
          expect(test_model.valid?).to be_truthy
        end

        specify 'max_hour still 23' do
          test_model.hour = 24
          expect(test_model.valid?).to be_falsey

          test_model.hour = 23
          expect(test_model.valid?).to be_truthy
        end
      end

      context 'max_hour' do
        let(:test_model) {
          time_hour_validator_class({ max_hour: 2000 }).new
        }

        specify 'max_hour now 2000' do
          test_model.hour = 2000
          expect(test_model.valid?).to be_truthy

          test_model.hour = 2001
          expect(test_model.valid?).to be_falsey
        end

        specify 'min_hour still 0' do
          test_model.hour = -1
          expect(test_model.valid?).to be_falsey

          test_model.hour = 0
          expect(test_model.valid?).to be_truthy
        end
      end
    end
  end
end

def time_hour_validator_class(options)
  Class.new(ValidatorsHelper::ValidationTester) do
    attr_accessor :hour

    validates :hour, time_hour: options
  end
end