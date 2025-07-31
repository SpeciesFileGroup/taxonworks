# Functions facilitating the use of  `taxonomy` (Shared::Taxonomy) objects
module TaxonNames::TaxonomyHelper

  # def ancestry_id_path
  # end

  # @return String
  #   all names joined with the delimiter
  def ancestry_path(ancestry, delimiter: '|')
    return nil if ancestry.blank?
    ancestry.shift # remove 'Root'
    ancestry.join(delimiter)
  end

end
