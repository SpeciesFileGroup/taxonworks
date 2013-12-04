require 'spec_helper'

describe Identifier::Guid do

  let(guid_identifier) {Idenfier::Guid.new}

  context 'validation' do
    context 'requires' do
      before(:each) {
        guid_identifier.valid?
      }
    end
  end

  specify 'namespace is nil' do
    guid_identifier.namespace = FactoryGirl.build(:valid_namespace)
    guid_identifier.valid?
    expect(guid_identifier.errors.include?(:namespace)).to be_true
  end




end
