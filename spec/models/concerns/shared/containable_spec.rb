require 'rails_helper'

describe 'Containables' do
  let(:containable_class) { TestContainable.new } 

  context "associationas" do
    specify "has one" do
      expect(containable_class).to respond_to(:container)
    end
  end 

  context "methods" do
    specify "contained?" do
      expect(containable_class.contained?).to eq(false)
    end
  end

end

class TestContainable < ActiveRecord::Base
  include FakeTable
  include Shared::Containable
end

