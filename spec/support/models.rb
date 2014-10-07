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

  # Model specific helpers

  def find_or_create_root_taxon_name
    if t = TaxonName.where(parent_id: nil).first
      return t
    else
      return FactoryGirl.create(:root_taxon_name)
    end
  end

end


