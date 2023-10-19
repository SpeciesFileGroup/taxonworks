class CachedMapItem::WebLevel1 < CachedMapItem

  SOURCE_GAZETEERS = %w{ne_states ne_countries}

  # Not implemented
  # If you start with these, use these
  AREA_EXCEPTIONS = [
    33893, # TDWG LVL 3 France
    34185, # TDWG LVL 4 France
  ].freeze


end
