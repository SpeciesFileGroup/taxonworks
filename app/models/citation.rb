# A Citation is an assertion that the subject (i.e. citation object/record/data instance), or some attribute of it, was referenced or originate in a Source. 
#
# @!attribute citation_object_type
#   @return [String]
#     Rails STI, the class of the object being cited 
#
# @!attribute source_id
#   @return [Integer]
#   the source ID
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute citation_object_id
#   @return [Integer]
#    Rails STI, the id of the object being cited 
#
# @!attribute pages
#   @return [String]
#     a specific location/localization for the data in the Source  
#
class Citation < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData
  include Shared::Notable

  belongs_to :citation_object, polymorphic: :true
  belongs_to :source, inverse_of: :citations

  has_many :citation_topics, inverse_of: :citation
  has_many :topics, through: :citation_topics

  validates_presence_of  :source_id
  validates_uniqueness_of :source_id, scope: [:citation_object_type, :citation_object_id, :pages]

  accepts_nested_attributes_for :citation_topics, allow_destroy: true, reject_if: :reject_citation_topics
  accepts_nested_attributes_for :topics, allow_destroy: true, reject_if: :reject_topic

  after_save :update_related_cached_values, if: 'is_original?'

  def update_related_cached_values
    if citation_object_type == 'TaxonName'
      citation_object.update_attribute(:cached_author_year, citation_object.get_author_and_year)
    end
    true
  end

  # @return [Scope of matching sources]
  def self.find_for_autocomplete(params)
    term    = params['term']
    ending  = term + '%'
    wrapped = '%' + term + '%'
    joins(:source).where('sources.cached ILIKE ? OR sources.cached ILIKE ? OR citation_object_type LIKE ?', ending, wrapped, ending).with_project_id(params[:project_id])
  end

  # @return [NoteObject]
  #   alias to simplify reference across classes 
  def annotated_object
    citation_object
  end

  # @return [Boolean]
  #   true if is_original is checked, false if nil/false 
  def is_original?
    is_original ? true : false
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

  protected

  def reject_citation_topics(attributed)
    attributes['id'].blank? && attributed['topic_id'].blank? && attributed['topic'].blank? && attributed['topic_attributes'].blank?
  end

  def reject_topic(attributed)
    attributed['name'].blank? || attributed['definition'].blank?
  end

end
