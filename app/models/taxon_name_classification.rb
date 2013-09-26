class TaxonNameClassification < ActiveRecord::Base
  belongs_to :taxon_name

  validates_presence_of  :taxon_name_id, :type

end
