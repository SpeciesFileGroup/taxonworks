require 'spec_helper'

# Projects are extended by various related concerns.  When 
# we get to testing them we will have to do this here:
#   Rails.application.eager_load!

describe Project do

  let(:project) {FactoryGirl.build(:project)}

  context 'associations' do
    context 'has_many' do
      specify 'project_members' do
        expect(project.project_members << ProjectMember.new).to be_true 
      end

      specify 'users' do
        expect(project.users << User.new).to be_true 
      end
    end
  end

  context 'workbench_settings' do
    before(:each) {
      project.name = 'My Project'
      project.save!
    }
    specify 'are set to default' do
      expect(project.workbench_settings).to eq(Project::DEFAULT_WORKBENCH_SETTINGS)
    end

    specify 'can be cleared with #clear_workbench_settings' do
      expect(project.clear_workbench_settings).to be_true
      expect(project.workbench_settings).to eq(Project::DEFAULT_WORKBENCH_SETTINGS)
    end

    specify 'default_path defaults to DEFAULT_WORKBENCH_STARTING_PATH' do 
      expect(project.workbench_starting_path).to eq(Project::DEFAULT_WORKBENCH_STARTING_PATH)
      expect(project.workbench_settings[:workbench_starting_path]).to eq(Project::DEFAULT_WORKBENCH_STARTING_PATH)
    end

  end

  context 'validation' do
    before(:each) do
      project.valid?
    end

    context 'requires' do
      specify 'name' do
        expect(project.errors.include?(:name)).to be_true
      end

      specify 'valid with name' do
        project.name = 'Project!'
        expect(project.valid?).to be_true
      end
    end
  end

 end
