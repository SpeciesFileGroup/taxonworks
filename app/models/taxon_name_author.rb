class TaxonNameAuthor < Role::ProjectRole
  include Housekeeping

  def self.human_name
    'Taxon name author'
  end
end
