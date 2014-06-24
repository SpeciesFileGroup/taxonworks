require 'spec_helper'

describe ProjectMember do

  let(:project_member) {FactoryGirl.build(:project_member) }

  context 'associations' do
    context 'belongs_to' do
      specify 'user' do
        expect(project_member).to respond_to(:user)
      end

      specify 'project' do
        expect(project_member).to respond_to(:project)
      end
    end
  end

  context 'validation' do

    before(:each) do
      project_member.valid?
    end

    specify 'user' do
      expect(project_member.errors.include?(:project)).to be_truthy
    end

    specify 'project' do
      expect(project_member.errors.include?(:user)).to be_truthy
    end

  end

end

