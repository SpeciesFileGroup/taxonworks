class TaxonNameRelationship < ActiveRecord::Base

  validates_presence_of :type, :subject_taxon_name_id, :object_taxon_name_id
 
  belongs_to :object, class_name: 'TaxonName', foreign_key: :subject_taxon_name_id
  belongs_to :subject, class_name: 'TaxonName', foreign_key: :subject_taxon_name_id

end
