require 'rails_helper'

describe 'Housekeeping::User' do

  # Do not extend these tests. This is just to ensure
  # we include both submodules when we 'require Housekeeping'.
  
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
end
