# Be sure to restart your server (or console) when you modify this file.

# All TaxonNameClass Classes

TAXON_NAME_CLASSES = TaxonNameClass.descendants

# Array of all ICZN TaxonNameClassification classes, as Strings
ICZN_TAXON_NAME_CLASS_NAMES = TaxonNameClass::Iczn.descendants.collect{|d| d.to_s}

# Array of all ICN TaxonNameClasses classes, as Strings
ICN_TAXON_NAME_CLASS_NAMES = TaxonNameClass::Icn.descendants.collect{|d| d.to_s}

# Array of all TaxonNameClasses classes, as Strings
TAXON_NAME_CLASS_NAMES = ICZN_TAXON_NAME_CLASS_NAMES + ICN_TAXON_NAME_CLASS_NAMES