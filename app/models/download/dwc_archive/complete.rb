# Only one per project.  Includes the complete current contents of DwCOccurrences.
class Download::DwcArchive::Complete < Download::DwcArchive

  # Can be built with/out data attributes 
  attr_accessor :predicate_extensions

  # Default values
  attribute :name, default: -> { "dwc-a_complete_#{DateTime.now}.zip" } 
  attribute :description, default: 'A Darwin Core archive of the complete TaxonWorks DwcOccurrence table'
  attribute :filename, default: -> { "dwc-a_complete_#{DateTime.now}.zip" } 
  attribute :expires, default: -> { 1.month.from_now } 
  attribute :request, default: -> { '/api/v1/downloads/build?type=Download::DwcArchive::Complete' } 
  attribute :is_public, default: -> { 1 } 

  after_save :build, unless: :ready? # prevent infinite loop callbacks
  
  validates_uniqueness_of :type, scope: [:project_id], message: 'Only one Download::DwcArchive::Complete is allowed. Destroy the old version first.'

  def build
    record_scope = ::DwcOccurrence.where(project_id: project_id)
    build_async(record_scope) 
  end

end
