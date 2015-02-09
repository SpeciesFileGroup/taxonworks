# A data attribute is used to attach an arbitrary predicate/literal pair to a data instance, essentially creating a user-defined triple.
#
# DataAttribute is only instantiated through its subclasses ImportAttribute or InternalAttribute
#
# @!attribute value 
#   @return [String]
#   The user provided data, e.g. RFD literal or object, i.e. RDF literal, i.e. data in a cell of a spreadsheet.  Always required.
#
# @!attribute attribute_subject_id 
#   @return [Integer]
#   The id of the subject (Rails polymorphic relationship). 
#
# @!attribute attribute_subject_type
#   @return [String]
#   THe class of the subject (Rails polymorphic relationship).
#
# @!attribute type 
#   @return [String]
#   The type of DataAttribute (Rails STI). 
#
class DataAttribute < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 
  include Shared::Annotates

  belongs_to :attribute_subject, polymorphic: true

  #following is the code before I tried to make annotates work - eef 2/9/15
  # Please DO NOT include the following:  (follows Identifier approach)
  #   validates_presence_of :attribute_subject_type, :attribute_subject_id
  #   validates :attribute_subject, presence: true
  validates_presence_of :type, :value
  validates_uniqueness_of :value, scope: [:attribute_subject_id, :attribute_subject_type, :type]

=begin
  # new code begin - eef 2/9/15
  validates_presence_of :type, :value
  validates :attribute_subject, presence: true

  before_validation :ensure_value_is_unique_in_scope

  def ensure_value_is_unique_in_scope
    errors.add(:value, 'Value is not unique within scope') if
      (false)    #TODO write this test
  end
  # new code end - eef 2/9/15
=end

  def self.find_for_autocomplete(params)
    where('value LIKE ?', "%#{params[:term]}%").with_project_id(params[:project_id])
  end

  # @return [NoteObject]
  #   alias to simplify reference across classes 
  def annotated_object
    attribute_subject
  end

end
