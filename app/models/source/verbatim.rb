# Verbatim - Subclass of Source that represents a pasted copy of a reference.
# This class is provided to support rapid data entry for later normalization.
# Once the Source::Verbatim information has been broken down into a a valid Source::Bibtex or Source:Human,
# the verbatim source is no longer available.
#
# @!attribute verbatim
#   This is the only valid attribute of Source::Verbatim. It is the verbatim representation of the source.
#
class Source::Verbatim < Source
  
  def authority_name
    nil
  end

  protected

  def set_cached_values
    self.cached_author_string = authority_name
    self.cached = self.verbatim
  end

end
