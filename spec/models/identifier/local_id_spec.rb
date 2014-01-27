require 'spec_helper'

describe Identifier::LocalId do
  let(:local_identifier) {Identifier::LocalId.new}

  context 'validation' do
    before(:each) {
      local_identifier.valid?
    }
    context 'requires' do
      specify 'namespace' do
        expect(local_identifier.errors.include?(:namespace)).to be_true
      end
    end
  end
end
