require 'spec_helper'

describe 'Housekeeping::User' do

  context 'Users' do

    let(:instance) {
      stub_model HousekeepingTestClass::WithUser, id: 10
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
      before(:each) {
        @i = HousekeepingTestClass::WithUser.new
      }

      context 'presence of the id itself' do
        before(:each) { $user_id = nil } 
        after(:each) { $user_id = 1 } # see spec/support/project_and_user.rb 

        specify 'created_by_id is required' do
          @i.valid?
          expect(@i.errors.include?(:creator)).to be_true
        end

        specify 'updated_by_id is required' do
          @i.valid?
          expect(@i.errors.include?(:updater)).to be_true
        end
      end

      context 'presence in database' do
        before(:each) { $user_id = 49999 } # better not be one, but fragile
        after(:each) { $user_id = 1 } # see spec/support/project_and_user.rb 

        specify 'creator must exist' do
          @i.valid? 
          expect(@i.errors.include?(:creator)).to be_true  
        end

        specify 'updater must exist' do
          @i.valid? 
          expect(@i.errors.include?(:updater)).to be_true  
        end
      end
    end

    context 'class method' do
      specify 'all creators' do
        expect(HousekeepingTestClass::WithUser).to respond_to(:all_creators)
        # expect(HousekeepingTestClass::WithUser.all_creators).to eq([])
      end
    end
    context 'instance methods' do
      specify 'alive?' do
        expect(instance).to respond_to(:alive?)
      end
    end
  end
  
  context 'Projects' do
    let(:instance) {
      stub_model HousekeepingTestClass::WithProject, id: 10
    }

    context 'associations' do
      specify 'project' do
        expect(instance).to respond_to(:project)
      end
    end

    context 'Project extensions' do
      before(:all) {
        d = HousekeepingTestClass::WithProject.new # Force Project extensions by instantiating an instance of the extended class
        @p = Project.new 
      }

      specify 'has_many :related_instances' do
        expect(@p).to respond_to(:with_projects)
      end

      context 'auto-population and validation' do
        before(:each) {
          @i = HousekeepingTestClass::WithProject.new
        }

        specify 'project_id is set with before_validation' do
          @i.valid? 
          expect(@i.project_id).to eq(1)  # see support/set_user_and_project
        end

        specify 'project is set from $project_id ' do
          $project_id = nil # TODO: make a with_no_project method 
          @i.valid?
          expect(@i.project_id.nil?).to be_true 
          expect(@i.errors.include?(:project)).to be_true
          $project_id = 1 # return the global to its state
        end

        specify 'project must exist' do
          $project_id = 342432
          @i.valid?  # even when set, it's not necessarily valid
          expect(@i.errors.include?(:project)).to be_true  # there is no project with id 1 in the present paradigm
          $project_id = 1
        end

        context 'belonging to a project' do
          before(:each) {
            @project1 = FactoryGirl.create(:valid_project)
            @project2 = FactoryGirl.create(:valid_project)
          }

          after(:each) {
            @project1.destroy
            @project2.destroy
          }

          after(:all) {
            $project_id = 1
          }

          specify 'scoped by a project' do
            @otu1 = Otu.create(project: @project1, name: 'Fus')
            @otu2 = Otu.create(project: @project2, name: 'Bus')

            expect(Otu.in_project(@project1).all).to eq([@otu1])
            expect(Otu.with_project_id(@project2.id).all).to eq([@otu2])

          end

          specify 'instance must belong to the project before save' do
            pending
            # $project_id = @project1.id
            # expect(@i.valid?).to be_true
            # expect(@i.project_id).to eq(@project1.id)
            # expect(@i.save).to be_true

            # @i.project_id = @project2.id 
            # expect{@i.save}.to raise_error
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
