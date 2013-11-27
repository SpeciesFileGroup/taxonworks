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

      specify 'created_by_id is required' do
        $user_id = nil # TODO: make a with_no_project method 
        @i.valid?
        expect(@i.errors.include?(:creator)).to be_true
        $user_id = 1 # return the global to its state
      end

      specify 'updated_by_id is required' do
        $user_id = nil # TODO: make a with_no_project method 
        @i.valid?
        expect(@i.errors.include?(:updater)).to be_true
        $user_id = 1 # return the global to its state
      end

      specify 'creator must exist' do
        @i.valid? 
        expect(@i.errors.include?(:creator)).to be_true  # there is no project with id 1 in the present paradigm
      end

      specify 'updater must exist' do
        @i.valid? 
        expect(@i.errors.include?(:updater)).to be_true  # there is no project with id 1 in the present paradigm
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
          @i.valid?  # even when set, it's not necessarily valid
          expect(@i.errors.include?(:project)).to be_true  # there is no project with id 1 in the present paradigm
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

end
