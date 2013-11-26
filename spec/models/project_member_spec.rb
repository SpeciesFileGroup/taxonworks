require 'spec_helper'

describe ProjectMember do

  let(:project_member) {ProjectMember.new}

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
      expect(project_member.errors.include?(:project_id)).to be_true
    end

    specify 'project' do
      expect(project_member.errors.include?(:user_id)).to be_true
    end

  end

end

