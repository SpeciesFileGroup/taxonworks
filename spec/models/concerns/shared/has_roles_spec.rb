require 'rails_helper'
describe 'Has_roles', type: :model do
  let(:class_with_roles) {TestHasRole.new}

  context 'associations' do
    specify 'has many roles' do
      expect(class_with_roles).to respond_to(:roles)
    end
  end

  context 'methods' do
    specify 'has_roles?' do
      expect(class_with_roles.has_roles?).to eq(false)
    end
    context 'object with roles on destroy' do
      specify 'attached roles are destroyed' do
        expect(Role.count).to eq(0)
        class_with_roles.roles << FactoryBot.build(:valid_role)
        class_with_roles.save
        expect(Role.count).to eq(1)
        expect(class_with_roles.destroy).to be_truthy
        expect(Role.count).to eq(0)
      end
    end
  end
end

class TestHasRole < ApplicationRecord
  include FakeTable
  include Shared::IsData::HasRoles
end

