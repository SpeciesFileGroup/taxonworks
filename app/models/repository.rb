# A Repository is a physical location that stores collection objects.
#
# In TaxonWorks, Repositories are presently built exclusively at http://grbio.org/.  
#
class Repository < ActiveRecord::Base
  include Housekeeping::Users
  include Shared::Notable
  include Shared::SharedAcrossProjects


  has_many :collection_objects, inverse_of: :repository, dependent: :restrict_with_error
  validates_presence_of :name, :url, :acronym, :status

  # TODO: @mjy What *is* the right construct for 'Repository'?
  def self.find_for_autocomplete(params)
    where('name LIKE ?', "#{params[:term]}%")
  end

end
