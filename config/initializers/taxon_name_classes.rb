# Be sure to restart your server (or console) when you modify this file.

# All TaxonNameClassification Classes

TAXON_NAME_CLASSES = TaxonNameClassification.descendants

# Array of all ICZN TaxonNameClassification classes, as Strings
ICZN_TAXON_NAME_CLASS_NAMES = TaxonNameClassification::Iczn.descendants.collect{|d| d.to_s}

# Array of all ICN TaxonNameClassificationes classes, as Strings
ICN_TAXON_NAME_CLASS_NAMES = TaxonNameClassification::Icn.descendants.collect{|d| d.to_s}

# Array of all TaxonNameClassificationes classes, as Strings
TAXON_NAME_CLASS_NAMES = ICZN_TAXON_NAME_CLASS_NAMES + ICN_TAXON_NAME_CLASS_NAMES