# A PreparationType describes how a collection object was prepared for preservation in a collection.  At present we're building a shared controlled vocabulary that
# we may ultimately try and turn into an ontology.
#
# @!attribute name
#   @return [String]
#     the name of the preparation 
#
# @!attribute definition
#   @return [String]
#     a definition describing the preparation 
#
class PreparationType < ActiveRecord::Base
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::IsData
  include Shared::Taggable
  include Shared::SharedAcrossProjects
 
  has_paper_trail

  has_many :collection_objects, dependent: :restrict_with_error
  validates_presence_of :name, :definition

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
