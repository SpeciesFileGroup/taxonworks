# Be sure to restart your server (or console) when you modify this file.

# Array of all ICZN and ICN TaxonNameClassification classes
TAXON_NAME_CLASSIFICATION_CLASSES = TaxonNameClassification.descendants 

# Array of all Latinized TaxonNameClassification classes, as Strings
LATINIZED_TAXON_NAME_CLASSIFICATION_NAMES = TaxonNameClassification::Latinized.descendants.collect{|d| d.to_s}

# Array of all ICZN TaxonNameClassification classes, as Strings
ICZN_TAXON_NAME_CLASSIFICATION_NAMES  = TaxonNameClassification::Iczn.descendants.collect{|d| d.to_s}

# Array of all ICN TaxonNameClassifications classes, as Strings
ICN_TAXON_NAME_CLASSIFICATION_NAMES = TaxonNameClassification::Icn.descendants.collect{|d| d.to_s}

TAXON_NAME_CLASSIFICATION_GENDER_CLASSES = TaxonNameClassification::Latinized::Gender.descendants

ICZN_TAXON_NAME_CLASSIFICATION_HASH = (ICZN_TAXON_NAME_CLASSIFICATION_NAMES + LATINIZED_TAXON_NAME_CLASSIFICATION_NAMES).inject({}) {
  |hsh, klass| hsh.merge(klass.constantize.name => klass)
}
 
ICN_TAXON_NAME_CLASSIFICATION_HASH = (ICN_TAXON_NAME_CLASSIFICATION_NAMES + LATINIZED_TAXON_NAME_CLASSIFICATION_NAMES).inject({}) {
  |hsh, klass| hsh.merge(klass.constantize.name => klass)
}
 


# Array of all TaxonNameClassifications classes, as Strings
TAXON_NAME_CLASSIFICATION_NAMES = ICN_TAXON_NAME_CLASSIFICATION_NAMES + ICZN_TAXON_NAME_CLASSIFICATION_NAMES + LATINIZED_TAXON_NAME_CLASSIFICATION_NAMES

# Array of all Unavailable and Invalid TaxonNameClassifications classes, as Strings
TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID = [
  TaxonNameClassification::Iczn::Unavailable,
  TaxonNameClassification::Iczn::Unavailable.descendants,
  TaxonNameClassification::Iczn::Available::Invalid,
  TaxonNameClassification::Iczn::Available::Invalid.descendants,
  TaxonNameClassification::Icn::NotEffectivelyPublished,
  TaxonNameClassification::Icn::NotEffectivelyPublished.descendants,
  TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
  TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished.descendants,
  TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate,
  TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate.descendants
].flatten.map(&:to_s)

TAXON_NAME_CLASS_NAMES_VALID = [
    TaxonNameClassification::Iczn::Available::Valid,
    TaxonNameClassification::Iczn::Available::Valid.descendants,
    TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::Correct,
    TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::Correct.descendants
].flatten.map(&:to_s)


