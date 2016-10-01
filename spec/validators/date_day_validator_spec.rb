require 'rails_helper'

RSpec.describe DateDayValidator, type: :validator, group: :validator do
  context 'validations' do
    context 'no parameters given for validator' do
      let(:test_model) {
        date_day_validator_class(true).new
      }

      specify 'empty day is valid' do
        expect(test_model.valid?).to be_truthy
      end

      specify 'default min day is 1' do
        test_model.day = 0
        expect(test_model.valid?).to be_falsey

        test_model.day = 1
        expect(test_model.valid?).to be_truthy
      end

      specify 'default max day is 31' do
        test_model.day = 32
        expect(test_model.valid?).to be_falsey

        test_model.day = 31
        expect(test_model.valid?).to be_truthy
      end
    end 

    context 'parameters given for validator' do
      context 'min_day' do
        let(:test_model) {
          date_day_validator_class({ min_day: 20 }).new
        }

        specify 'min_day now 20' do
          test_model.day = 19
          expect(test_model.valid?).to be_falsey

          test_model.day = 20
          expect(test_model.valid?).to be_truthy
        end

        specify 'max_day still 31' do
          test_model.day = 32
          expect(test_model.valid?).to be_falsey

          test_model.day = 31
          expect(test_model.valid?).to be_truthy
        end
      end

      context 'max_day' do
        let(:test_model) {
          date_day_validator_class({ max_day: 20 }).new
        }

        specify 'max_day now 20' do
          test_model.day = 20
          expect(test_model.valid?).to be_truthy

          test_model.day = 21
          expect(test_model.valid?).to be_falsey
        end

        specify 'min_day still 1' do
          test_model.day = 0
          expect(test_model.valid?).to be_falsey

          test_model.day = 1
          expect(test_model.valid?).to be_truthy
        end
      end

      context 'year_sym and month_sym' do
        let(:test_model) {
          date_day_validator_class({ year_sym: :year, month_sym: :month }).new
        }

        specify 'invalid month adds error message' do
          test_model.year = Time.now.year
          test_model.month = 45
          test_model.day = 3
          expect(test_model.valid?).to be_falsey
          expect(test_model.errors.messages[:month].include?("45 is not a valid month")).to be true
        end

        specify 'invalid day adds error message' do
          test_model.year = Time.now.year
          test_model.month = 12
          test_model.day = 45
          expect(test_model.valid?).to be_falsey
          expect(test_model.errors.messages[:day].include?("45 is not a valid day for the month provided")).to be true
        end

        specify 'calculates correct max_day' do
          test_model.year = 2015
          test_model.month = 2    # Feb
          test_model.day = 28
          expect(test_model.valid?).to be_truthy

          test_model.day = 30
          expect(test_model.valid?).to be_falsey
        end
      end
    end
  end
end

def date_day_validator_class(options)
  Class.new(ValidatorsHelper::ValidationTester) do
    attr_accessor :day
    attr_accessor :year
    attr_accessor :month

    validates :day, date_day: options
  end
end