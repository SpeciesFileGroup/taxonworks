# Verbatim - Subclass of Source that represents a pasted copy of a reference.
#   This class is provided to support rapid data entry for later normalization.
#   Once the Source::Verbatim information has been broken down into a a valid Source::Bibtex or Source:Human,
#   the verbatim source is no longer available.
# @!attribute verbatim
class Source::Verbatim < Source
end
