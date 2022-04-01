class TaxonNameAuthor < Role::ProjectRole

  def self.human_name
    'Taxon name author'
  end

  def year_active_year
    role_object.year_of_publication
  end

end
