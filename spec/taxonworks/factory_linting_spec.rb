require 'rspec'
require 'rails_helper'

# These are meta-tests. To run lint => true tests set
# the environment variable TAXONWORKS_TEST_LINTING=true, for example
#    TAXONWORKS_TEST_LINTING=true spring rspecspec/factory_linting_spec.rb  
# 
describe 'TaxonWorksFactories' do
  context 'FactoryGirl linting', :lint => true do

    before {
      ProjectsAndUsers.spin_up_projects_users_and_housekeeping
    }

    specify 'of valid_ factories' do
      factories_to_lint = FactoryGirl.factories.select do |factory|
        factory.name =~ /^valid_/
      end
      expect(FactoryGirl.lint factories_to_lint).to be_nil
    end

  end

end
