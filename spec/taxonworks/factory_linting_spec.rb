require 'rspec'
require 'rails_helper'

# These are meta-tests. To run lint => true tests set
# the environment variable TAXONWORKS_TEST_LINTING=true, for example
#    export TAXONWORKS_TEST_LINTING=true && spring rspec spec/taxonworks/factory_linting_spec.rb
#    or
#    `rspec ... -t lint:true`
#
describe 'TaxonWorksFactories', lint: :true, group: :lint do

  before {
    ProjectsAndUsers.spin_up_projects_users_and_housekeeping
  }

  specify 'models have corresponding "valid_" factories' do
    factories_to_lint = FactoryBot.factories.select do |factory|
      factory.name =~ /^valid_/
    end
    expect(FactoryBot.lint factories_to_lint).to be_nil
  end


end
