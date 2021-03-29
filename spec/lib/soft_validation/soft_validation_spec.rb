require 'rails_helper'
require 'lib/soft_validation_helpers'

describe 'SoftValidation (instance)', group: :soft_validation do
  let(:soft_validation) {SoftValidation::SoftValidation.new}
  context 'attributes' do
    specify 'attribute' do
      expect(soft_validation).to respond_to(:attribute)
    end

    specify 'message' do
      expect(soft_validation).to respond_to(:message)
    end

    specify 'soft_validation_method' do
      expect(soft_validation).to respond_to(:soft_validation_method)
    end

    specify 'resolution' do
      expect(soft_validation).to respond_to(:resolution)
    end

    specify 'success_message' do
      expect(soft_validation).to respond_to(:success_message)
    end

    specify 'failure_message' do
      expect(soft_validation).to respond_to(:failure_message)
    end

    specify 'fixed' do
      expect(soft_validation).to respond_to(:fixed)
      soft_validation.fixed = :fixed
      expect(soft_validation.fixed?).to be_truthy
    end
  end

  specify 'result_message()' do
    soft_validation.failure_message = 'a'
    soft_validation.success_message = 'a'
    expect(soft_validation).to respond_to(:result_message)
  end

end
