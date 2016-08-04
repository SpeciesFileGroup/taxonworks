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
class TaxonNameClassification < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData
  include SoftValidation

  belongs_to :taxon_name, inverse_of: :taxon_name_classifications

  before_validation :validate_taxon_name_classification
  before_validation :validate_uniqueness_of_latinized
  validates_presence_of :taxon_name, presence: true
  validates_presence_of :type, presence: true
  validates_uniqueness_of :taxon_name_id, scope: :type

  validate :nomenclature_code_matches

  scope :where_taxon_name, -> (taxon_name) {where(taxon_name_id: taxon_name)}
  scope :with_type_string, -> (base_string) {where('type LIKE ?', "#{base_string}" ) }
  scope :with_type_base, -> (base_string) {where('type LIKE ?', "#{base_string}%" ) }
  scope :with_type_array, -> (base_array) {where('type IN (?)', base_array ) }
  scope :with_type_contains, -> (base_string) {where('type LIKE ?', "%#{base_string}%" ) }

  soft_validate(:sv_proper_classification, set: :proper_classification)
  soft_validate(:sv_validate_disjoint_classes, set: :validate_disjoint_classes)
  soft_validate(:sv_not_specific_classes, set: :not_specific_classes)

  after_save :set_cached_names_for_taxon_names
  after_destroy :set_cached_names_for_taxon_names

  def nomenclature_code
    return :iczn if type.match(/::Iczn/)
    return :icn if type.match(/::Icn/)
    return nil
  end

  # @return [String]
  #   the class name, "validated" against the known list of names
  def type_name
   r = self.type.to_s
   TAXON_NAME_CLASSIFICATION_NAMES.include?(r) ? r : nil
  end

  def type_class=(value)
    write_attribute(:type, value.to_s)
  end

  def type_class
    r = read_attribute(:type).to_s
    r = TAXON_NAME_CLASSIFICATION_NAMES.include?(r) ? r.safe_constantize : nil
  end

  # @return [String]
  #   a humanized class name, with code appended to differentiate 
  #   !! explored idea of LABEL in individual subclasses, use this if this doesn't work
  #   this is helper-esqe, but also useful in validation, so here for now
  def classification_label
    return nil if type_name.nil?
    type_name.demodulize.underscore.humanize.downcase + 
      (nomenclature_code ? " [#{nomenclature_code}]" : '')
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

  # @todo Perhaps not inherit these three methods?
  
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

  def set_cached_names_for_taxon_names
    begin
      TaxonName.transaction do
        t = self.taxon_name
        if self.type_name =~ /Fossil|Hybrid/
          t.update_columns(cached: t.get_full_name,
                           cached_html: t.get_full_name_html)
        elsif TAXON_NAME_CLASS_NAMES_VALID.include?(self.type_name)
          vn = t.get_valid_taxon_name
          vn.list_of_invalid_taxon_names.each do |s|
            s.update_column(:cached_valid_taxon_name_id, vn.id)
          end
        end
      end
      rescue
    end
    false
  end

  #region Validation
  # @todo validate, that all the taxon_classes in the table could be linked to taxon_classes in classes (if those had changed)
  def validate_uniqueness_of_latinized
    if /Latinized/.match(self.type_name)
      lat = TaxonNameClassification.where(taxon_name_id: self.taxon_name_id).with_type_contains('Latinized').not_self(self)
      unless lat.empty?
        if /Gender/.match(lat.first.type_name)
          errors.add(:taxon_name_id, 'The Gender is already selected')
        elsif /PartOfSpeech/.match(lat.first.type_name)
          errors.add(:taxon_name_id, 'The Part of speech is already selected')
        end
      end
    end
  end

  #endregion

  #region Soft validation

  def sv_proper_classification
    if TAXON_NAME_CLASSIFICATION_NAMES.include?(self.type)
      # self.type_class is a Class
      if not self.type_class.applicable_ranks.include?(self.taxon_name.rank_class.to_s)
        soft_validations.add(:type, 'The status is unapplicable to the name of ' + self.taxon_name.rank_class.rank_name + ' rank')
      end
    end
    y = self.taxon_name.year_of_publication
    if not y.nil?
      if y > self.type_class.code_applicability_end_year || y < self.type_class.code_applicability_start_year
        soft_validations.add(:type, 'The status is unapplicable to the name published in ' + y.to_s)
      end
    end
  end

  def sv_validate_disjoint_classes
    classifications = TaxonNameClassification.where_taxon_name(self.taxon_name).not_self(self)
    classifications.each  do |i|
      soft_validations.add(:type, "Conflicting with another status: '#{i.type_name}'") if self.type_class.disjoint_taxon_name_classes.include?(i.type_name)
    end
  end

  # TODO: These soft validations should be added to individual classes!
  def sv_not_specific_classes
    case self.type_name
      when 'TaxonNameClassification::Iczn::Available'
        soft_validations.add(:type, 'Please specify if the name is valid or invalid')
      when 'TaxonNameClassification::Iczn::Unavailable'
        soft_validations.add(:type, 'Please specify the reasons for the name being unavailable')
      when 'TaxonNameClassification::Iczn::Available::Invalid'
        soft_validations.add(:type, 'Please replace with appropriate relationship')
      when 'TaxonNameClassification::Iczn::Available::Invalid::Homonym'
        soft_validations.add(:type, 'Please replace with appropriate relationship')
      when 'TaxonNameClassification::Iczn::Available::Valid'
        soft_validations.add(:type, 'Please replace with appropriate relationship')
      when 'TaxonNameClassification::Iczn::Unavailable::Suppressed'
        soft_validations.add(:type, 'Please specify the reasons for the name being suppressed')
      when 'TaxonNameClassification::Iczn::Unavailable::Excluded'
        soft_validations.add(:type, 'Please specify the reasons for the name being excluded')
      when 'TaxonNameClassification::Iczn::Unavailable::NomenNudum'
        soft_validations.add(:type, 'Please specify the reasons for the name being nomen nudum')
      when 'TaxonNameClassification::Iczn::Unavailable::NonBinomial'
        soft_validations.add(:type, 'Please specify the reasons for the name being non binomial')
      when 'TaxonNameClassification::Icn::EffectivelyPublished'
        soft_validations.add(:type, 'Please specify if the name is validly or invalidly published')
      when 'TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished'
        soft_validations.add(:type, 'Please specify the reasons for the name being invalidly published')
      when 'TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished'

        soft_validations.add(:type, 'Please specify if the name is legitimate or illegitimate')
      when 'TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate'
        soft_validations.add(:type, 'Please specify the reasons for the name being Legitimate')
      when 'TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate'
        soft_validations.add(:type, 'Please specify the reasons for the name being Illegitimate')
    end
  end

  #endregion

  def self.find_for_autocomplete(params)
    where(id: params[:term]).with_project_id(params[:project_id])
  end

  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

  def self.annotates?
    true
  end

  def annotated_object
    taxon_name
  end

  private

  def nomenclature_code_matches
    if taxon_name && type && nomenclature_code
      errors.add(:taxon_name, "missmatched with asserted nomenclature code") if nomenclature_code != taxon_name.rank_class.nomenclatural_code
    end
  end

  def validate_taxon_name_classification
    errors.add(:type, "Status not found") if !self.type.nil? and !TAXON_NAME_CLASSIFICATION_NAMES.include?(self.type.to_s)
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
