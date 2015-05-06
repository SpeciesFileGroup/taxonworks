# Citation is like Roles in that it is also a linking table between a data object & a source.
# (Assertion that the subject was referenced in a source)
class Citation < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData

  belongs_to :citation_object, polymorphic: :true
  belongs_to :source, inverse_of: :citations

  has_many :citation_topics, inverse_of: :citation

  validates_presence_of :citation_object_id, :citation_object_type, :source_id
  validates_uniqueness_of :source_id, scope: [:citation_object_type, :citation_object_id]

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
