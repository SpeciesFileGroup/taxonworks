# Load the rails application.
require File.expand_path('../application', __FILE__)

# Initialize the rails application.
TaxonWorks::Application.initialize!

TaxonWorks::Application.configure do
  config.after_initialize { NomenclaturalRankOrder.populate_db }
end