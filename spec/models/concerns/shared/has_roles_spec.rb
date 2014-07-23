require 'rails_helper'
describe 'Citable', :type => :model do
  let(:class_with_roles) { TestHasRole.new } 
 
  context "associations" do
    specify "has many roles" do
      expect(class_with_roles).to respond_to(:roles)
    end
  end

  context "methods" do
    specify "has_roles?" do
      expect(class_with_roles.has_roles?).to eq(false)
    end
  end
end

class TestHasRole < ActiveRecord::Base
  include FakeTable
  include Shared::HasRoles
end

