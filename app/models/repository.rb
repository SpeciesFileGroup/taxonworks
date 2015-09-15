# A Repository is a physical location that stores collection objects.
#
# In TaxonWorks, repositories are presently built exclusively at http://grbio.org/.
#
# @!attribute name
#   @return [String]
#   @todo
#
# @!attribute url
#   @return [String]
#   @todo
#
# @!attribute acronym
#   @return [String]
#   @todo
#
# @!attribute status
#   @return [String]
#   the project ID
#
# @!attribute institutional_LSID
#   @return [String]
#   @todo
#
# @!attribute is_index_herbariorum
#   @return [Boolean]
#   @todo
#
class Repository < ActiveRecord::Base
  include Housekeeping::Users
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
