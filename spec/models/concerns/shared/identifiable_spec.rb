require 'rails_helper'
describe 'Identifiable', :type => :model do
  let(:identifiable_class) { TestIdentifiable.new } 
 
  context 'associations' do
    specify 'has many identifiers' do
      expect(identifiable_class.identifiers << Identifier.new).to be_truthy
    end
  end

  context "methods" do
    specify ".identified?" do
      expect(identifiable_class.identified?).to eq(false)
    end

    specify ".with_identifier(namespace, identifier)" do

    end

  end

  


end

class TestIdentifiable < ActiveRecord::Base
  include FakeTable
  include Shared::Identifiable
end


