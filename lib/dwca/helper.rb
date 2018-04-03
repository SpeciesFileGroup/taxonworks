module Dwca::Helper

  # Assume a single range.  Extend as we need for ranges.
  # @param [String] eventDate
  # @return [Cronic] parse result
  def parse_date(eventDate)
    # TODO: detect ranges
    Chronic.parse(eventDate)
  end

end

