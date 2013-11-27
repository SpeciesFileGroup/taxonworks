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
  end


  # Don't repeat all tests, just make sure we get one of each extension.
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
  class WithBoth < ActiveRecord::Base 
   extend FakeTable 
   include Housekeeping 
  end

  class WithUser < ActiveRecord::Base
    extend FakeTable 
    include Housekeeping::Users 
  end

  class WithProject < ActiveRecord::Base
    extend FakeTable 
    include Housekeeping::Projects 
  end

end
