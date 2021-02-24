# A special purpose notes field that records the notes of someone observing one or more collection objects.
#
# Includes verbatim block of text (perhaps json too ultimately) that details observations on a collection object.
# Should only include notes on CollectionObjects, not field observations, i.e. this is a precursor of a
# CollectionObject instance.
#
# Example usages:
# 1) Recording notes metadata about a image that contains multiple slides or non-emunmarated collection objects
# 2) While working in a collection a user rapidly types all labels/metadata from a specimen into one field, and moves
#     on.  This data is later broken down into individual records
#
# @!attribute data
#   @return [String]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class CollectionObjectObservation < ApplicationRecord
  include Housekeeping
  include Shared::Tags
  include Shared::Notes
  include Shared::Depictions
  include Shared::IsData

  ignore_whitespace_on(:data)

  has_many :derived_collection_objects, inverse_of: :collection_object_observation
  has_many :collection_objects, through: :derived_collection_objects

  validates_presence_of :data

  # @param [ActionController::Parameters] params
  # @return [Scope]
  def self.find_for_autocomplete(params)
    term = "#{params[:term]}%"
    where('data LIKE ? OR data ILIKE ? OR data = ?', term, "#{term}%", '%term')
      .where(project_id: params[:project_id])
  end

end
