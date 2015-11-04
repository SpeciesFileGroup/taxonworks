# A Repository is a physical location that stores collection objects.
#
# In TaxonWorks, repositories are presently built exclusively at http://grbio.org/.
#
# @!attribute name
#   @return [String]
#    the name of the repository
#
# @!attribute url
#   @return [String]
#    see  http://grbio.org/
#
# @!attribute acronym
#   @return [String]
#     a short form name for the repository  
#
# @!attribute status
#   @return [String]
#     see   http://grbio.org/
#
# @!attribute institutional_LSID
#   @return [String]
#    sensu  http://grbio.org/
#
# @!attribute is_index_herbariorum
#   @return [Boolean]
#    see  http://grbio.org/
#
class Repository < ActiveRecord::Base
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::Notable
  include Shared::IsData
  include Shared::IsApplicationData

  has_many :collection_objects, inverse_of: :repository, dependent: :restrict_with_error
  validates_presence_of :name, :url, :acronym, :status

  def self.find_for_autocomplete(params)
    Queries::RepositoryAutocompleteQuery.new(params[:term]).all
  end

  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

end
