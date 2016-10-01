require 'rails_helper'

RSpec.describe DateTimeValidator, type: :validator, group: :validator do
  specify 'testing' do
    expect(true).to be true
    test_model = date_time_base_validator_class(true).new
    expect(test_model.valid?).to be_truthy
  end

  context 'validations' do
    context 'no parameters given for validator' do
      specify 'empty attribute is valid' do
        test_model = date_time_base_validator_class(true).new
        expect(test_model.valid?).to be_truthy
      end

      context 'default error messages occur' do
        let(:test_model) {
          date_time_base_validator_class({ allow_blank: false }).new
        }

        after(:each) {
          expect(test_model.errors.messages[:attribute].include?("must be an integer between 1 and 100")).to be true
        }

        specify "can't be blank and default error message" do
          test_model.valid?
          expect(test_model.errors.messages[:attribute].include?("can't be blank")).to be true
        end

        specify 'is not an integer and default error message' do
          test_model.attribute = "4"
          test_model.valid?
          expect(test_model.errors.messages[:attribute].include?("is not an integer")).to be true
        end

        specify 'not in range and default error message' do
          test_model.attribute = 101
          test_model.valid?
          expect(test_model.errors.messages[:attribute].include?("not in range")).to be true
        end
      end
    end

    context 'parameters given for validator' do
      context 'allow_blank' do
        context 'true' do
          let(:test_model) {
            date_time_base_validator_class({ allow_blank: true }).new
          }

          specify 'empty attribute, model valid' do
            expect(test_model.valid?).to be_truthy
          end

          specify 'valid attribute, model valid' do
            test_model.attribute = 15
            expect(test_model.valid?).to be_truthy
          end
        end

        context 'false' do
          let(:test_model) {
            date_time_base_validator_class({ allow_blank: false }).new
          }

          specify 'empty attribute, model invalid' do
            expect(test_model.valid?).to be_falsey
          end

          specify 'valid attribute, model valid' do
            test_model.attribute = 15
            expect(test_model.valid?).to be_truthy
          end
        end
      end
    end

    context 'message' do
      specify 'custom message occurs' do
        custom_message = "this is a custom message"
        test_model = date_time_base_validator_class({ allow_blank: false, message: custom_message}).new
        test_model.valid?
        expect(test_model.errors.messages[:attribute].include?(custom_message)).to be true
      end
    end
  end
end

class DateTimeBaseValidator < DateTimeValidator
  def validate_each(record, attribute, value)
    @min_value = options.fetch(:min_value, 1)
    @max_value = options.fetch(:max_value, 100)
    super
  end
end

def date_time_base_validator_class(options)
  Class.new(ValidatorsHelper::ValidationTester) do
    attr_accessor :attribute

    validates :attribute, date_time_base: options
  end
end