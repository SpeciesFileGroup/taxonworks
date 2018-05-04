# Verbatim - Subclass of Source that represents a pasted copy of a reference.
# This class is provided to support rapid data entry for later normalization.
# Once the Source::Verbatim information has been broken down into a a valid Source::Bibtex or Source:Human,
# the verbatim source is no longer available.
#
# @!attribute verbatim
#   @return [String]
#   This is the only valid attribute of Source::Verbatim. It is the verbatim representation of the source.
#
class Source::Verbatim < Source

  validates_presence_of :verbatim
  validate :only_verbatim_is_populated

  # @return [Nil]
  def authority_name
    nil
  end

  # @return [Nil]
  def date
    nil
  end

  # @return [Source, Boolean]
  def generate_bibtex
    return false if self.verbatim.blank?
    result = Source.new_from_citation(citation: verbatim)
    if result.type == 'Source::Bibtex'
      result
    else
      false
    end
  end

  # @param [Source] source
  # @return [Boolean]
  # def similar(source)
  #   false
  # end

  # @param [Source] source
  # @return [Boolean]
  # def identical(source)
  #   false
  # end

  protected

  # @return [Ignored]
  def set_cached
    update_column(:cached, verbatim)
  end

  # @return [Ignored]
  def only_verbatim_is_populated
    self.attributes.each do |k, v|
      next if %w{id type cached verbatim created_by_id updated_by_id created_at updated_at}.include?(k)
      errors.add(k, 'can not be provided to a verbatim reference') if !v.blank?
    end
  end

end
