# Darwin Core Archive (DWC-A) shared constants and utilities
module Export::Dwca

  # Delimiter used for concatenating multiple values in DwC fields
  # Used when multiple items (e.g., references, media, identifiers) need to be
  # represented in a single Darwin Core field.
  DELIMITER = ' | '.freeze

end
