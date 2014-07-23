require 'rails_helper'

describe Identifier::Local, :type => :model do
  let(:local_identifier) {Identifier::Local.new}

  context 'validation' do
    before(:each) {
      local_identifier.valid?
    }
    context 'requires' do
      specify 'namespace' do
        expect(local_identifier.errors.include?(:namespace)).to be_truthy
      end
    end
  end
end
