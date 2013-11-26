require 'spec_helper'

describe Project do

  let(:project) {Project.new}

  context 'associations' do
    context 'has_many' do
      specify 'project_members' do
        expect(project).to respond_to(:project_members)
      end

      specify 'users' do
        expect(project).to respond_to(:users)
      end
    end
  end

  context 'validation' do
    before(:each) do
      project.valid?
    end
    specify 'name' do
      expect(project.errors.include?(:name)).to be_true
    end
  end

end
