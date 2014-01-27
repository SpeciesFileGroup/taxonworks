# Be sure to restart your server (or console) when you modify this file.

# All TaxonNameClassification Classes

# Array of all ICZN TaxonNameClassification classes
ICZN_TAXON_NAME_CLASSES = TaxonNameClassification::Iczn.descendants

# Array of all ICN TaxonNameClassification classes
ICN_TAXON_NAME_CLASSES = TaxonNameClassification::Icn.descendants

# Array of all ICZN and ICN TaxonNameClassification classes
TAXON_NAME_CLASSES = ICZN_TAXON_NAME_CLASSES + ICZN_TAXON_NAME_CLASSES

# Array of all ICZN TaxonNameClassification classes, as Strings
ICZN_TAXON_NAME_CLASS_NAMES = ICZN_TAXON_NAME_CLASSES.collect{|d| d.to_s}

# Array of all ICN TaxonNameClassificationes classes, as Strings
ICN_TAXON_NAME_CLASS_NAMES = ICN_TAXON_NAME_CLASSES.collect{|d| d.to_s}

# Array of all TaxonNameClassificationes classes, as Strings
TAXON_NAME_CLASS_NAMES = ICZN_TAXON_NAME_CLASS_NAMES + ICN_TAXON_NAME_CLASS_NAMES

# Array of all Unavailable and Invalid TaxonNameClassificationes classes, as Strings
TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID = [TaxonNameClassification::Iczn::Unavailable.to_s] +
    TaxonNameClassification::Iczn::Unavailable.descendants.collect{|d| d.to_s} +
    [TaxonNameClassification::Iczn::Available::Invalid.to_s] +
    TaxonNameClassification::Iczn::Available::Invalid.descendants.collect{|d| d.to_s} +
    [TaxonNameClassification::Icn::NotEffectivelyPublished.to_s] +
    TaxonNameClassification::Icn::NotEffectivelyPublished.descendants.collect{|d| d.to_s} +
    [TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished.to_s] +
    TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|d| d.to_s} +
    [TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate.to_s] +
    TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate.descendants.collect{|d| d.to_s}