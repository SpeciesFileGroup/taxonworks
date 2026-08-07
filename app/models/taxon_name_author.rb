class TaxonNameAuthor < Role::ProjectRole

  def self.human_name
    'Taxon name author'
  end

  def year_active_year
    role_object.year_of_publication
  end

  private

  # TaxonName authors should only trigger author related updates, not name structure!
  def cached_triggers
    return { TaxonName: [:set_cached_author_columns ] }
  end

end
