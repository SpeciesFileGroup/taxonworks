require 'rails_helper'

describe 'Housekeeping::Project' do

  context 'Projects' do
    let(:instance) {
      stub_model HousekeepingTestClass::WithProject, id: 10
    }

    let!(:user) {FactoryGirl.create(:valid_user, id: 1)}

    context 'associations' do
      specify 'belongs_to project' do
        expect(instance).to respond_to(:project)
      end
    end

    context 'Project extensions' do
      before(:all) {
        forced = HousekeepingTestClass::WithProject.new # Force Project extensions by instantiating an instance of the extended class
        $user_id = 1
      }

      let(:project) { Project.new(name: "Foo") }

      specify 'has_many :related_instances' do
        expect(project).to respond_to(:with_projects)
      end

      context 'auto-population and validation' do
        let(:i) {  HousekeepingTestClass::WithProject.new }

        context 'when $project_id is set' do
          before(:each) {
            project.save!
            $project_id = project.id 
          }

          specify 'project_id is set with before_validation' do
            i.valid? 
            expect(i.project_id).to eq(project.id)  # see support/set_user_and_project
          end

          specify 'project is set from $project_id ' do
            $project_id = nil # TODO: make a with_no_project method 
            i.valid?
            expect(i.project_id.nil?).to be_truthy
            expect(i.errors.include?(:project)).to be_truthy
          end

          specify 'project must exist' do
            $project_id = 342432
            i.valid?  # even when set, it's not necessarily valid
            expect(i.errors.include?(:project)).to be_truthy  # there is no project with id 1 in the present paradigm
          end

          context 'belonging to a project' do
            let(:project1) {FactoryGirl.create(:valid_project, id: 1) }
            let(:project2) {FactoryGirl.create(:valid_project, id: 2) }

            specify 'scoped by a project' do
              @otu1 = Otu.create(project: project1, name: 'Fus')
              @otu2 = Otu.create(project: project2, name: 'Bus')

              expect(Otu.in_project(project1).to_a).to eq([@otu1])
              expect(Otu.with_project_id(project2.id).to_a).to eq([@otu2])
            end

            xspecify 'instance must belong to the project before save' do
              # $project_id = @project1.id
              # expect(i.valid?).to be_truthy
              # expect(i.project_id).to eq(@project1.id)
              # expect(i.save).to be_truthy

              # i.project_id = @project2.id 
              # expect{i.save}.to raise_error
            end
          end
        end
      end
    end
  end
end

module HousekeepingTestClass
  class WithBoth  < ActiveRecord::Base 
    include FakeTable  
    include Housekeeping 
  end

  class WithProject < ActiveRecord::Base
    include FakeTable 
    include Housekeeping::Projects 
  end

end
