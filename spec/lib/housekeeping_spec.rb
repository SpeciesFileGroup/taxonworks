require 'rails_helper'

describe 'Housekeeping::User' do

  let!(:user) {FactoryGirl.create(:valid_user, id: 1)}

  context 'Users' do

    let(:instance) {
      stub_model(HousekeepingTestClass::WithUser, id: 10)
    }

    context 'associations' do
      specify 'creator' do
        expect(instance).to respond_to(:creator)
      end

      specify 'updater' do
        expect(instance).to respond_to(:updater)
      end
    end

    context 'auto-population and validation' do
      let(:i) { HousekeepingTestClass::WithUser.new }

      context 'presence of the id itself' do
        before(:each) { $user_id = nil } 

        specify 'created_by_id is required' do
          i.valid?
          expect(i.errors.include?(:creator)).to be_truthy
        end

        specify 'updated_by_id is required' do
          i.valid?
          expect(i.errors.include?(:updater)).to be_truthy
        end
      end

      context 'presence in database' do
        before(:each) { $user_id = 49999 } # better not be one, but fragile

        specify 'creator must exist' do
          i.valid? 
          expect(i.errors.include?(:creator)).to be_truthy
        end

        specify 'updater must exist' do
          i.valid? 
          expect(i.errors.include?(:updater)).to be_truthy
        end
      end
    end

    context 'class method' do
      specify 'all creators' do
        expect(HousekeepingTestClass::WithUser).to respond_to(:all_creators)
      end

      specify 'all updaters' do
        expect(HousekeepingTestClass::WithUser).to respond_to(:all_updaters)
      end
    end
  end

  context 'Projects' do
    let(:instance) {
      stub_model HousekeepingTestClass::WithProject, id: 10
    }

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

  # Do not extend these tests. This
  # is just to ensure we include both submodules when
  # we 'require Housekeeping'
  context 'Housekeeping' do
    let(:instance) {
      stub_model HousekeepingTestClass::WithBoth, id: 10
    }
    context 'associations' do
      specify 'project' do
        expect(instance).to respond_to(:project)
      end
      specify 'updater' do
        expect(instance).to respond_to(:updater)
      end
    end
  end

end

module HousekeepingTestClass
  class WithBoth  < ActiveRecord::Base 
    include FakeTable  
    include Housekeeping 
  end

  class WithUser < ActiveRecord::Base
    include FakeTable 
    include Housekeeping::Users 
  end

  class WithProject < ActiveRecord::Base
    include FakeTable 
    include Housekeeping::Projects 
  end

  class WithTimestamps < ActiveRecord::Base
    include FakeTable 
    include Housekeeping::Timestamps
  end

end
