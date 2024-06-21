RSpec.configure do |config|
  config.before(:all, type: :model) do
    ProjectsAndUsers.spin_up_projects_users_and_housekeeping
  end

  config.before(:each, type: :model) do
    Current.project_id = 1
    Current.user_id = 1
  end

  config.after(:all, type: :model) {
    ProjectsAndUsers.clean_slate
  }
end

# Helpers for Model related testing/helpers.
#
# These methods are available throughout specs.
module ModelHelper

  # Returns the name of the TW factory for a class, includes
  # the formatting for nested subclasses.
  def class_factory_name(klass)
    klass.name.tableize.singularize.gsub('/', '_')
  end

  # Return the name of the valid TW factory for the class. This
  # factory should be directly creatable, e.g. Factory.create(valid_class_factory_name(Otu))
  def valid_class_factory_name(klass)
    "valid_#{class_factory_name(klass)}"
  end

  def find_or_create_root_taxon_name
    if t = TaxonName.where(parent_id: nil).first
      return t
    else
      return FactoryBot.create(:root_taxon_name)
    end
  end

  # @return [Integer, nil]
  #    accessor to the global
  def user_id
    Current.user_id
  end

  # @return [Integer, nil]
  #    accessor to the global
  def project_id
    Current.project_id
  end
end
