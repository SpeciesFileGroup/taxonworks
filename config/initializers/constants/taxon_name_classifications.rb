# Be sure to restart your server (or console) when you modify this file.

# Array of all ICZN and ICN TaxonNameClassification classes
TAXON_NAME_CLASSIFICATION_CLASSES = TaxonNameClassification.descendants.freeze 

# Array of all Latinized TaxonNameClassification classes, as Strings
LATINIZED_TAXON_NAME_CLASSIFICATION_NAMES = TaxonNameClassification::Latinized.descendants.collect{|d| d.to_s}.freeze

# Array of all ICZN TaxonNameClassification classes, as Strings
ICZN_TAXON_NAME_CLASSIFICATION_NAMES  = TaxonNameClassification::Iczn.descendants.collect{|d| d.to_s}.freeze

# Array of all ICN TaxonNameClassifications classes, as Strings
ICN_TAXON_NAME_CLASSIFICATION_NAMES = TaxonNameClassification::Icn.descendants.collect{|d| d.to_s}.freeze

# Array of all ICNB TaxonNameClassifications classes, as Strings
ICNB_TAXON_NAME_CLASSIFICATION_NAMES = TaxonNameClassification::Icnb.descendants.collect{|d| d.to_s}.freeze

TAXON_NAME_CLASSIFICATION_GENDER_CLASSES = TaxonNameClassification::Latinized::Gender.descendants.freeze

ICZN_TAXON_NAME_CLASSIFICATION_HASH = (ICZN_TAXON_NAME_CLASSIFICATION_NAMES + LATINIZED_TAXON_NAME_CLASSIFICATION_NAMES).inject({}) {
  |hsh, klass| hsh.merge(klass.constantize.name => klass)
}.freeze
 
ICN_TAXON_NAME_CLASSIFICATION_HASH = (ICN_TAXON_NAME_CLASSIFICATION_NAMES + LATINIZED_TAXON_NAME_CLASSIFICATION_NAMES).inject({}) {
  |hsh, klass| hsh.merge(klass.constantize.name => klass)
}.freeze

ICNB_TAXON_NAME_CLASSIFICATION_HASH = (ICNB_TAXON_NAME_CLASSIFICATION_NAMES + LATINIZED_TAXON_NAME_CLASSIFICATION_NAMES).inject({}) {
    |hsh, klass| hsh.merge(klass.constantize.name => klass)
}.freeze

# Array of all TaxonNameClassifications classes, as Strings
TAXON_NAME_CLASSIFICATION_NAMES = (ICN_TAXON_NAME_CLASSIFICATION_NAMES + ICNB_TAXON_NAME_CLASSIFICATION_NAMES + ICZN_TAXON_NAME_CLASSIFICATION_NAMES + LATINIZED_TAXON_NAME_CLASSIFICATION_NAMES).freeze

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
  TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate.descendants,
  TaxonNameClassification::Icnb::NotEffectivelyPublished,
  TaxonNameClassification::Icnb::NotEffectivelyPublished.descendants,
  TaxonNameClassification::Icnb::EffectivelyPublished::InvalidlyPublished,
  TaxonNameClassification::Icnb::EffectivelyPublished::InvalidlyPublished.descendants,
  TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Illegitimate,
  TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Illegitimate.descendants,
].flatten.map(&:to_s).freeze

TAXON_NAME_CLASS_NAMES_VALID = [
    TaxonNameClassification::Iczn::Available::Valid,
    TaxonNameClassification::Iczn::Available::Valid.descendants,
    TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::Correct,
    TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::Correct.descendants,
    TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Legitimate::Correct,
    TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Legitimate::Correct.descendants
].flatten.map(&:to_s).freeze


# JSON supporting
module TaxonNameClassificationsHelper
  
  # @return [Hash]
  def self.collection(classifications)
    classifications.select{ |s| s.assignable }.inject({}) {|hsh, c| 
      hsh.merge!(c.name => attributes(c))
    }
  end

  # @return [Hash]
  def self.attributes(classification)
    return { 
      name: classification.label,
      type: classification.to_s,
      applicable_ranks: classification.applicable_ranks
    }
  end

  # @return [Hash]
  def self.descendants_collection(base_classification)
    collection(base_classification.descendants)
  end
end


TAXON_NAME_CLASSIFICATION_JSON = {
  iczn: {
    tree: ApplicationEnumeration.nested_subclasses(TaxonNameClassification::Iczn),
    all: TaxonNameClassificationsHelper::descendants_collection( TaxonNameClassification::Iczn ),
    common: TaxonNameClassificationsHelper.collection([
      TaxonNameClassification::Iczn::Unavailable,
      TaxonNameClassification::Iczn::Unavailable::NomenNudum,
      TaxonNameClassification::Iczn::Available::Invalid::Homonym,
      TaxonNameClassification::Iczn::Available::Valid::NomenDubium,
      TaxonNameClassification::Iczn::Fossil 
    ])
  }, 
  icn: {
    tree: ApplicationEnumeration.nested_subclasses(TaxonNameClassification::Icn),
    all: TaxonNameClassificationsHelper::descendants_collection( TaxonNameClassification::Icn ),
    common: TaxonNameClassificationsHelper.collection([
      TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
      TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished::NomenNudum,
      TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::Homonym,
      TaxonNameClassification::Icn::Fossil
    ])
  },
  icnb: {
    tree: ApplicationEnumeration.nested_subclasses(TaxonNameClassification::Icnb),
    all: TaxonNameClassificationsHelper::descendants_collection( TaxonNameClassification::Icnb ),
    common: TaxonNameClassificationsHelper.collection([
    
    ])
  },
  latinized: {
    tree: ApplicationEnumeration.nested_subclasses(TaxonNameClassification::Latinized),
    all: TaxonNameClassificationsHelper::descendants_collection( TaxonNameClassification::Latinized ),
    common: TaxonNameClassificationsHelper.collection([
      TaxonNameClassification::Icnb::EffectivelyPublished::InvalidlyPublished,
      TaxonNameClassification::Icnb::EffectivelyPublished::InvalidlyPublished::NomenNudum,
      TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Illegitimate::Homonym
    ])
  }
}
