

# New corresponding to the administration of this instance of TaxonWorks
class News::Administration < News 
  validates :project_id, absence: true
end
