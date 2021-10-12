require_dependency Rails.root.to_s + '/app/models/nomenclatural_rank.rb'
require_dependency Rails.root.to_s + '/app/models/taxon_name_relationship.rb'

# A {https://github.com/SpeciesFileGroup/nomen NOMEN} derived classfication (roughly, a status) for a {TaxonName}.
#
# @!attribute taxon_name_id
#   @return [Integer]
#     the id of the TaxonName being classified
#
# @!attribute type
#   @return [String]
#     the type of classifiction (Rails STI)
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class TaxonNameClassification < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Notes
  include Shared::IsData
  include SoftValidation

  belongs_to :taxon_name, inverse_of: :taxon_name_classifications

  before_validation :validate_taxon_name_classification
  before_validation :validate_uniqueness_of_latinized
  validates_presence_of :taxon_name
  validates_presence_of :type
  validates_uniqueness_of :taxon_name_id, scope: :type

  validate :nomenclature_code_matches

  scope :where_taxon_name, -> (taxon_name) {where(taxon_name_id: taxon_name)}
  scope :with_type_string, -> (base_string) {where('taxon_name_classifications.type LIKE ?', "#{base_string}" ) }
  scope :with_type_base, -> (base_string) {where('taxon_name_classifications.type LIKE ?', "#{base_string}%" ) }
  scope :with_type_array, -> (base_array) {where('taxon_name_classifications.type IN (?)', base_array ) }
  scope :with_type_contains, -> (base_string) {where('taxon_name_classifications.type LIKE ?', "%#{base_string}%" ) }

  soft_validate(:sv_proper_classification,
                set: :proper_classification,
                name: 'Applicable status',
                description: 'Check the status applicability.' )

  soft_validate(:sv_proper_year,
                set: :proper_classification,
                name: 'Applicable protonym year',
                description: 'Check that the status is compatible with the year of publication of taxon.' )

  soft_validate(:sv_validate_disjoint_classes,
                set: :validate_disjoint_classes,
                name: 'Conflicting status',
                description: 'Taxon has two conflicting statuses' )

  soft_validate(:sv_not_specific_classes,
                set: :not_specific_classes,
                name: 'Not specific status',
                description: 'More specific statuses are preffered, for example: "Nomen nudum, no description" is better than "Nomen nudum".' )

  after_save :set_cached
  after_destroy :set_cached

  def nomenclature_code
    return :iczn if type.match(/::Iczn/)
    return :icnp if type.match(/::Icnp/)
    return :icvcn if type.match(/::Icvcn/)
    return :icn if type.match(/::Icn/)
    return nil
  end

  def self.label
    name.demodulize.underscore.humanize.downcase.gsub(/\d+/, ' \0 ').squish
  end

  # @return class
  #   this method calls Module#module_parent
  def self.parent
    self.module_parent
  end

  # @return [String]
  #   the class name, "validated" against the known list of names
  def type_name
    r = self.type.to_s
    ::TAXON_NAME_CLASSIFICATION_NAMES.include?(r) ? r : nil
  end

  def type_class=(value)
    write_attribute(:type, value.to_s)
  end

  def type_class
    r = read_attribute(:type).to_s
    r = ::TAXON_NAME_CLASSIFICATION_NAMES.include?(r) ? r.safe_constantize : nil
  end

  # @return [String]
  #   a humanized class name, with code appended to differentiate
  #   !! explored idea of LABEL in individual subclasses, use this if this doesn't work
  #   this is helper-esqe, but also useful in validation, so here for now
  def classification_label
    return nil if type_name.nil?
    type_name.demodulize.underscore.humanize.downcase.gsub(/\d+/, ' \0 ').squish #+
      #(nomenclature_code ? " [#{nomenclature_code}]" : '')
  end

  # @return [String]
  #   the NOMEN id for this classification
  def nomen_id
    self.class::NOMEN_URI.split('/').last
  end

  # Attributes can be overridden in descendants

  # @return [Integer]
  # the minimum year of applicability for this class, defaults to 1
  def self.code_applicability_start_year
    1
  end

  # @return [Integer]
  # the last year of applicability for this class, defaults to 9999
  def self.code_applicability_end_year
    9999
  end

  # @return [Array of Strings of NomenclaturalRank names]
  # nomenclatural ranks to which this class is applicable, that is, only {TaxonName}s of these {NomenclaturalRank}s may be classified as this class
  def self.applicable_ranks
    []
  end

  # @return [Array of Strings of TaxonNameClassification names]
  # the disjoint (inapplicable) {TaxonNameClassification}s for this class, that is, {TaxonName}s classified as this class can not be additionally classified under these classes
  def self.disjoint_taxon_name_classes
    []
  end

  # @return [String, nil]
  #  if applicable, a DWC gbif status for this class
  def self.gbif_status
    nil
  end

  def self.assignable
    false
  end

 #def self.common
 #  false
 #end

  # @todo Perhaps not inherit these three meaxonNameClassificationsHelper::descendants_collection( TaxonNameClassification::Latinized )thods?

  # @return [Array of Strings]
  #   the possible suffixes for a {TaxonName} name (species) classified as this class, for example see {TaxonNameClassification::Latinized::Gender::Masculine}
  #   used to validate gender agreement of species name with a genus
  def self.possible_species_endings
    []
  end

  # @return [Array of Strings]
  #   the questionable suffixes for a {TaxonName} name classified as this class, for example see {TaxonNameClassification::Latinized::Gender::Masculine}
  def self.questionable_species_endings
    []
  end

  # @return [Array of Strings]
  # the possible suffixes for a {TaxonName} name (genus) classified as this class, for example see {TaxonNameClassification::Latinized::Gender::Masculine}
  def self.possible_genus_endings
    []
  end

  def self.nomen_uri
    const_defined?(:NOMEN_URI, false) ? self::NOMEN_URI : nil
  end

  def set_cached
    set_cached_names_for_taxon_names
  end

  # TODO: move these to individual classes?!
  def set_cached_names_for_taxon_names
    begin
      TaxonName.transaction_with_retry do
        t = taxon_name

        if type_name =~ /(Fossil|Hybrid|Candidatus)/
          n = t.get_full_name
          t.update_columns(
            cached: n,
            cached_html: t.get_full_name_html(n),
            cached_original_combination: t.get_original_combination,
            cached_original_combination_html: t.get_original_combination_html
          )
        elsif type_name =~ /Latinized::PartOfSpeach/
          n = t.get_full_name
          t.update_columns(
              cached: n,
              cached_html: t.get_full_name_html(n),
              cached_original_combination: t.get_original_combination,
              cached_original_combination_html: t.get_original_combination_html
          )

          TaxonNameRelationship::OriginalCombination.where(subject_taxon_name: t).collect{|i| i.object_taxon_name}.uniq.each do |t1|
            t1.update_cached_original_combinations
          end

          TaxonNameRelationship::Combination.where(subject_taxon_name: t).collect{|i| i.object_taxon_name}.uniq.each do |t1|
            t1.update_column(:verbatim_name, t1.cached) if t1.verbatim_name.nil?
            n = t1.get_full_name
            t1.update_columns(
                cached: n,
                cached_html: t1.get_full_name_html(n)
            )
          end
        elsif type_name =~ /Latinized::Gender/
          t.descendants.with_same_cached_valid_id.each do |t1|
            n = t1.get_full_name
            t1.update_columns(
                cached: n,
                cached_html: t1.get_full_name_html(n)
            )
          end

          TaxonNameRelationship::OriginalCombination.where(subject_taxon_name: t).collect{|i| i.object_taxon_name}.uniq.each do |t1|
            t1.update_cached_original_combinations
          end

          TaxonNameRelationship::Combination.where(subject_taxon_name: t).collect{|i| i.object_taxon_name}.uniq.each do |t1|
            t1.update_column(:verbatim_name, t1.cached) if t1.verbatim_name.nil?
            n = t1.get_full_name
            t1.update_columns(
                cached: n,
                cached_html: t1.get_full_name_html(n)
            )
          end
        elsif TAXON_NAME_CLASS_NAMES_VALID.include?(type_name)
#          TaxonName.where(cached_valid_taxon_name_id: t.cached_valid_taxon_name_id).each do |vn|
          #            vn.update_column(:cached_valid_taxon_name_id, vn.get_valid_taxon_name.id)  # update self too!
          #          end
          vn = t.get_valid_taxon_name
          vn.update_columns(
            cached_valid_taxon_name_id: vn.id,
            cached_is_valid: !vn.unavailable_or_invalid?) # Do not change!  
          vn.list_of_invalid_taxon_names.each do |s|
            s.update_columns(
              cached_valid_taxon_name_id: vn.id,
              cached_is_valid: false)
            s.combination_list_self.each do |c|
              c.update_columns(cached_valid_taxon_name_id: vn.id)
            end
          end
          t.combination_list_self.each do |c|
            c.update_columns(cached_valid_taxon_name_id: vn.id)
          end
        else
          t.update_columns(cached_is_valid: false)
        end
      end
    rescue ActiveRecord::RecordInvalid
      false
    end
    true
  end

  #region Validation
  def validate_uniqueness_of_latinized
    true # moved to subclasses
  end

  #endregion

  #region Soft validation

  def sv_proper_classification
    if TAXON_NAME_CLASSIFICATION_NAMES.include?(self.type)
      # self.type_class is a Class
      if not self.type_class.applicable_ranks.include?(self.taxon_name.rank_string)
        soft_validations.add(:type, "The status '#{self.classification_label}' is unapplicable to the taxon #{self.taxon_name.cached_html} at the rank of #{self.taxon_name.rank_class.rank_name}")
      end
    end
  end

  def sv_proper_year
    y = self.taxon_name.year_of_publication
    if !y.nil? && (y > self.type_class.code_applicability_end_year || y < self.type_class.code_applicability_start_year)
      soft_validations.add(:type, "The status '#{self.classification_label}' is unapplicable to the taxon #{self.taxon_name.cached_html} published in the year #{y}")
    end
  end

  def sv_validate_disjoint_classes
    classifications = TaxonNameClassification.where_taxon_name(self.taxon_name).not_self(self)
    classifications.each  do |i|
      soft_validations.add(:type, "The status  '#{self.classification_label}' conflicting with another status: '#{i.classification_label}'") if self.type_class.disjoint_taxon_name_classes.include?(i.type_name)
    end
  end

  def sv_not_specific_classes
    true # moved to subclasses
  end

  #endregion

  def self.annotates?
    true
  end

  def annotated_object
    taxon_name
  end

  private

  def nomenclature_code_matches
    if taxon_name && type && nomenclature_code
      errors.add(:taxon_name, "#{taxon_name.cached_html} belongs to #{taxon_name.rank_class.nomenclatural_code} nomenclatural code, but the status used from #{nomenclature_code} nomenclature code") if nomenclature_code != taxon_name.rank_class.nomenclatural_code
    end
  end

  def validate_taxon_name_classification
    errors.add(:type, 'Status not found') if !self.type.nil? and !TAXON_NAME_CLASSIFICATION_NAMES.include?(self.type.to_s)
  end


  # @todo move these to a shared library (see NomenclaturalRank too)
  def self.collect_to_s(*args)
    args.collect{|arg| arg.to_s}
  end

  # @todo move these to a shared library (see NomenclaturalRank too)
  # !! using this strongly suggests something can be optimized, meomized etc.
  def self.collect_descendants_to_s(*classes)
    ans = []
    classes.each do |klass|
      ans += klass.descendants.collect{|k| k.to_s}
    end
    ans
  end

  # @todo move these to a shared library (see NomenclaturalRank too)
  # !! using this strongly suggests something can be optimized, meomized etc.
  def self.collect_descendants_and_itself_to_s(*classes)
    classes.collect{|k| k.to_s} + self.collect_descendants_to_s(*classes)
  end

end

Dir[Rails.root.to_s + '/app/models/taxon_name_classification/**/*.rb'].each { |file| require_dependency file }
