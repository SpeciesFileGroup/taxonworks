# A biological associations graph is...
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute name
#   @return [String]
#   @todo
#
# @!attribute source_id
#   @return [Integer]
#   the source ID
#
class BiologicalAssociationsGraph < ActiveRecord::Base
  include Housekeeping
  include Shared::Citable
  include Shared::IsData 

  belongs_to :source
  has_many :biological_associations_biological_associations_graphs, inverse_of: :biological_associations_graph
  has_many :biological_associations, through: :biological_associations_biological_associations_graphs

  def self.find_for_autocomplete(params)
    Queries::BiologicalAssociationsGraphAutocompleteQuery.new(params[:term]).all.where(project_id: params[:project_id])
  end

end
