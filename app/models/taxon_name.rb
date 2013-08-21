class TaxonName < ActiveRecord::Base

  validates_presence_of :name, :rank

  before_save :generate_cached_name

  protected 

  def generate_cached_name
    self.cached_name = self.name
  end

end
