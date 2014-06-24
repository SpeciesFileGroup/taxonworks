require 'spec_helper'
describe Identifier::Global do

  let(:guid_identifier) {Identifier::Global.new}

  context 'validation' do
    context 'requires' do
      before(:each) {
        guid_identifier.valid?
      }
    end
  end

  specify 'namespace_id is nil' do
    guid_identifier.namespace_id = FactoryGirl.create(:valid_namespace).id
    guid_identifier.valid?
    expect(guid_identifier.errors.include?(:namespace_id)).to be_truthy
  end

end
