# A special purpose notes field that records the notes of someone observing one or more collection objects.
#
# Includes verbatim block of text (perhaps json too ultimately) that details observations on a collection object.  
# Should only include notes on CollectionObjects, not field observations, i.e. this is a precursor of a CollectionObject instance.
#
# Example usages:
# 1) Recording notes metadata about a image that contains multiple slides or non-emunmarated collection objects
# 2) While working in a collection a user rapidly types all labels/metadata from a specimen into one field, and moves on.  This data
# is later broken down into individual records
#
# @!attribute data
#   @return [String]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class CollectionObjectObservation < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData
  include Shared::Taggable
  include Shared::Notable
  include Shared::Depictions

  has_many :derived_collection_objects, inverse_of: :collection_object_observations
  has_many :collection_objects, through: :derived_collection_objects

  validates_presence_of :data

  def self.find_for_autocomplete(params)
    term = "#{params[:term]}%"
    where('data LIKE ? OR data ILIKE ? OR data = ?', term, "#{term}%", "%term").where(project_id: params[:project_id])
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
