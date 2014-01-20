
class TaxonName < ActiveRecord::Base

  include Housekeeping
  include Shared::Identifiable
  include Shared::Citable
  include SoftValidation

  acts_as_nested_set scope: [:project_id]

  belongs_to :source 
 
  has_many :taxon_name_classifications

  #relationships as a subject
  has_many :taxon_name_relationships, foreign_key: :subject_taxon_name_id

  #relationships as an object
  has_many :related_taxon_name_relationships, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

  has_many :taxon_name_author_roles, class_name: 'TaxonNameAuthor', as: :role_object
  has_many :taxon_name_authors, through: :taxon_name_author_roles, source: :person

  scope :with_rank_class, -> (rank_class_name) {where(rank_class: rank_class_name)}
  scope :with_parent_taxon_name, -> (parent) {where(parent_id: parent)}
  scope :with_base_of_rank_class, -> (rank_class) {where('rank_class LIKE ?', "#{rank_class}%")}
  scope :with_rank_class_including, -> (include_string) {where('rank_class LIKE ?', "%#{include_string}%")}
  scope :descendants_of, -> (taxon_name) {where('(taxon_names.lft >= ?) and (taxon_names.lft <= ?) and (taxon_names.id != ?) and (taxon_names.project_id = ?)', taxon_name.lft, taxon_name.rgt, taxon_name.id, taxon_name.project_id  )}
  scope :ancestors_of, -> (taxon_name) {where('(taxon_names.lft <= ?) and (taxon_names.rgt >= ?) and (taxon_names.id != ?) and (taxon_names.project_id = ?)', taxon_name.lft, taxon_name.rgt, taxon_name.id, taxon_name.project_id  )}
  scope :ancestors_and_descendants_of, -> (taxon_name) {
    where('(((taxon_names.lft >= ?) AND (taxon_names.lft <= ?)) OR
           ((taxon_names.lft <= ?) AND (taxon_names.rgt >= ?))) AND
           (taxon_names.id != ?) AND (taxon_names.project_id = ?)',
          taxon_name.lft, taxon_name.rgt,  taxon_name.lft, taxon_name.rgt, taxon_name.id, taxon_name.project_id  ) }

  # A specific relationship
  scope :as_subject_with_taxon_name_relationship, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where(taxon_name_relationships: {type: taxon_name_relationship}) }
  scope :as_subject_with_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "#{taxon_name_relationship}%").references(:taxon_name_relationships) }
  scope :as_subject_without_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('(taxon_name_relationships.type NOT LIKE ?) OR (taxon_name_relationships.subject_taxon_name_id IS NULL)', "#{taxon_name_relationship}%").references(:taxon_name_relationships) }

  scope :as_subject_with_taxon_name_relationship_containing, -> (taxon_name_relationship) { includes(:taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "%#{taxon_name_relationship}%").references(:taxon_name_relationships) }
  scope :as_object_with_taxon_name_relationship, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where(taxon_name_relationships: {type: taxon_name_relationship}) }
  scope :as_object_with_taxon_name_relationship_base, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "#{taxon_name_relationship}%").references(:related_taxon_name_relationships) }
  scope :as_object_with_taxon_name_relationship_containing, -> (taxon_name_relationship) { includes(:related_taxon_name_relationships).where('taxon_name_relationships.type LIKE ?', "%#{taxon_name_relationship}%").references(:related_taxon_name_relationships) }
  scope :with_taxon_name_relationship, -> (relationship) {
    joins('LEFT OUTER JOIN taxon_name_relationships tnr1 ON taxon_names.id = tnr1.subject_taxon_name_id').
        joins('LEFT OUTER JOIN taxon_name_relationships tnr2 ON taxon_names.id = tnr2.object_taxon_name_id').
        where('tnr1.type = ? OR tnr2.type = ?', relationship, relationship)
  }

  # *Any* relationship where there IS a relationship for a subject/object/both
  scope :with_taxon_name_relationships_as_subject, -> {joins(:taxon_name_relationships)}
  scope :with_taxon_name_relationships_as_object, -> {joins(:related_taxon_name_relationships)}
  scope :with_taxon_name_relationships, -> {
    joins('LEFT OUTER JOIN taxon_name_relationships tnr1 ON taxon_names.id = tnr1.subject_taxon_name_id').
        joins('LEFT OUTER JOIN taxon_name_relationships tnr2 ON taxon_names.id = tnr2.object_taxon_name_id').
        where('tnr1.subject_taxon_name_id IS NOT NULL OR tnr2.object_taxon_name_id IS NOT NULL')
  }

  # *Any* relationship where there is NOT a relationship for a subject/object/both
  scope :without_subject_taxon_name_relationships, -> { includes(:taxon_name_relationships).where(taxon_name_relationships: {subject_taxon_name_id: nil}) }
  scope :without_object_taxon_name_relationships, -> { includes(:related_taxon_name_relationships).where(taxon_name_relationships: {object_taxon_name_id: nil}) }
  scope :without_taxon_name_relationships, -> {
    joins('LEFT OUTER JOIN taxon_name_relationships tnr1 ON taxon_names.id = tnr1.subject_taxon_name_id').
        joins('LEFT OUTER JOIN taxon_name_relationships tnr2 ON taxon_names.id = tnr2.object_taxon_name_id').
        where('tnr1.subject_taxon_name_id IS NULL AND tnr2.object_taxon_name_id IS NULL')
  }

  soft_validate(:sv_missing_fields, set: :missing_fields)
  soft_validate(:sv_parent_is_valid_name, set: :parent_is_valid_name)
  soft_validate(:sv_source_older_then_description, set: :source_older_then_description)

  validates_presence_of :type
  validates_presence_of :rank_class, if: Proc.new { |tn| [Protonym].include?(tn.class)}
  validates_presence_of :name, if: Proc.new { |tn| [Protonym].include?(tn.class)}

  before_validation :set_type_if_empty,
                    :check_format_of_name,
                    :validate_rank_class_class,
                    :validate_parent_rank_is_higher,
                    :check_new_rank_class,
                    :check_new_parent_class,
                    :validate_source_type

  before_validation :set_cached_name,
              :set_cached_author_year,
              :set_cached_higher_classification

  def all_taxon_name_relationships
    # (self.taxon_name_relationships & self.related_taxon_name_relationships)

    # !! If self relatinships are every made possiblepossible this needs a DISTINCT clause
    TaxonNameRelationship.find_by_sql("SELECT taxon_name_relationships.* FROM taxon_name_relationships WHERE taxon_name_relationships.subject_taxon_name_id = #{self.id} UNION
                         SELECT taxon_name_relationships.* FROM taxon_name_relationships WHERE taxon_name_relationships.object_taxon_name_id = #{self.id}")
  end

  def all_related_taxon_names
    TaxonNameRelationship.find_by_sql("SELECT DISTINCT tn.* FROM taxon_names tn 
                     LEFT JOIN taxon_name_relationships tnr1 ON tn.id = tnr1.subject_taxon_name_id
                     LEFT JOIN taxon_name_relationships tnr2 ON tn.id = tnr2.object_taxon_name_id
                     WHERE tnr1.object_taxon_name_id = #{self.id} OR tnr2.subject_taxon_name_id = #{self.id};")
  end

  def related_taxon_names
    TaxonName.find_by_sql("SELECT DISTINCT tn.* FROM taxon_names tn
                      LEFT JOIN taxon_name_relationships tnr1 ON tn.id = tnr1.subject_taxon_name_id
                      LEFT JOIN taxon_name_relationships tnr2 ON tn.id = tnr2.object_taxon_name_id
                      WHERE tnr1.object_taxon_name_id = #{self.id} OR tnr2.subject_taxon_name_id = #{self.id};")
  end

  def rank
    ::RANKS.include?(self.rank_class) ? self.rank_class.rank_name : nil
  end

  def rank_string
    self.rank_class.to_s
  end

  def rank_class=(value)
    write_attribute(:rank_class, value.to_s)
  end

  def rank_class
    r = read_attribute(:rank_class)
    Ranks.valid?(r) ? r.constantize : r 
  end

  def nomenclature_date
    family_before_1961 = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type('TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961')
    if family_before_1961.empty?
      self.source ? self.source.nomenclature_date.to_time : (self.year_of_publication ? Time.utc(self.year_of_publication, 12, 31) : nil)
    else
      obj = family_before_1961.first.object_taxon_name
      obj.source ? obj.source.nomenclature_date.to_time : (obj.year_of_publication ? Time.utc(obj.year_of_publication, 12, 31) : nil)
    end
  end

  def ancestor_at_rank(rank)
   TaxonName.ancestors_of(self).with_rank_class( Ranks.lookup(self.rank_class.nomenclatural_code, rank)).first
  end

  def unavailable_or_invalid?
    case self.rank_class.nomenclatural_code
      when :iczn
        if !TaxonNameRelationship::Iczn::Invalidating.where_subject_is_taxon_name(self).empty? || !TaxonNameClassification.where_taxon_name(self).with_type_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).empty?
          return true
        end
      when :icz
        if !TaxonNameRelationship::Icn::Unaccepting.where_subject_is_taxon_name(self).empty? || !TaxonNameClassification.where_taxon_name(self).with_type_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).empty?
          return true
        end
    end
    return false
  end

  def get_valid_taxon_name
    vn = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID)
    (vn.count == 1) ? vn.first.object_taxon_name : self
  end

  protected 

  #region Set cached fields

  def set_type_if_empty
    self.type = 'Protonym' if self.type.nil?
  end

  def set_cached_name
    # see config/initializers/ranks for GENUS_AND_SPECIES_RANKS
    if !GENUS_AND_SPECIES_RANK_NAMES.include?(self.rank_class.to_s)
      cached_name = nil
    else
      genus = ''
      subgenus = ''
      species = ''
      (self.ancestors + [self]).each do |i|
        if GENUS_AND_SPECIES_RANK_NAMES.include?(i.rank_class.to_s)
          case i.rank_class.rank_name
          when "genus" then genus = i.name + ' '
          when "subgenus" then subgenus += i.name + ' '
          when "section" then subgenus += 'sect. ' + i.name + ' '
          when "subsection" then subgenus += 'subsect. ' + i.name + ' '
          when "series" then subgenus += 'ser. ' + i.name + ' '
          when "subseries" then subgenus += 'subser. ' + i.name + ' '
          when "species" then species += i.name + ' '
          when "subspecies" then species += i.name + ' '
          when "variety" then species += 'var. ' + i.name + ' '
          when "subvariety" then species += 'subvar. ' + i.name + ' '
          when "form" then species += 'f. ' + i.name + ' '
          when "subform" then species += 'subf. ' + i.name + ' '
          else
          end
        end
      end
      subgenus = '(' + subgenus.strip! + ') ' unless subgenus.empty?
      cached_name = (genus + subgenus + species).strip!
    end
    self.cached_name = cached_name
  end

  def set_cached_original_combination
    #TODO: set cached original combination
    true
  end

  def set_cached_primary_homonym
    #TODO: set cached primary homonym, including variable spelling
    true
  end

  def set_cached_secondary_homonym
    #TODO: set cached secondary homonym, including variable spelling
    true
  end

  def set_cached_author_year
    if self.rank.nil?
      ay = ([self.verbatim_author] + [self.year_of_publication]).compact.join(', ')
    else
      rank = Object.const_get(self.rank_class.to_s)
      if rank.nomenclatural_code == :iczn
        ay = ([self.verbatim_author] + [self.year_of_publication]).compact.join(', ')
        if NomenclaturalRank::Iczn::SpeciesGroup.ancestors.include?(self.rank_class)
          if self.original_combination_genus.name != self.ancestor_at_rank('genus').name and !self.original_combination_genus.name.to_s.empty?
            ay = '(' + ay + ')' unless ay.empty?
          end
        end
      elsif rank.nomenclatural_code == :icn
        t = [self.verbatim_author]
        t += ['(' + self.year_of_publication.to_s + ')'] unless self.year_of_publication.nil?
        ay = t.compact.join(' ')
      else
        ay = ([self.verbatim_author] + [self.year_of_publication]).compact.join(' ')
      end
    end
    self.cached_author_year = ay
  end

  def set_cached_higher_classification
    # see config/initializers/ranks for FAMILY_AND_ABOVE_RANKS
    hc = (self.ancestors + [self]).select{|i| FAMILY_AND_ABOVE_RANK_NAMES.include?(i.rank_class.to_s)}.collect{|i| i.name}.join(':')
    self.cached_higher_classification = hc
  end

  #endregion

  #region Validation

  def validate_parent_rank_is_higher
    if self.rank_class == NomenclaturalRank
      true
    elsif self.parent.nil?
      errors.add(:parent_id, 'A parent is not selected')
    elsif self.type == 'Combination'
      true
    elsif RANKS.index(self.rank_class) <= RANKS.index(self.parent.rank_class)
      errors.add(:parent_id, "The parent rank (#{self.parent.rank_class.rank_name}) is not higher than #{self.rank_class.rank_name}")
    elsif !self.children.empty? && self.rank_class != self.rank_class_was
      if RANKS.index(self.rank_class) >= self.children.collect{|r| RANKS.index(r.rank_class)}.max
        errors.add(:rank_class, "The taxon rank (#{self.rank_class.rank_name}) is not higher than child ranks")
      end
    end
  end

  def validate_rank_class_class
    if self.type == 'Combination'
      errors.add(:rank_class, 'Combination should not have rank') if self.rank_class
    elsif self.type == 'Protonym'
      unless Ranks.valid?(rank_class)
        errors.add(:rank_class, 'Rank not found')
      end
    end
  end

  def check_format_of_name
    if self.rank_class && self.rank_class.respond_to?(:validate_name_format)
      self.rank_class.validate_name_format(self)
    end
  end

  def check_new_rank_class
    if self.rank_class != self.rank_class_was && !self.rank_class_was.nil?
      old_rank_group = self.rank_class_was.constantize.parent
      if self.rank_class.parent != old_rank_group
        errors.add(:rank_class, "A new taxon rank (#{self.rank_class.rank_name}) should be in the #{old_rank_group.rank_name}")
      end
    end
  end

  def check_new_parent_class
    if self.parent_id != self.parent_id_was && !self.parent_id_was.nil? && self.rank_class.nomenclatural_code == :iczn
      old_parent = TaxonName.find_by_id(self.parent_id_was)
      if (self.rank_class.rank_name == 'subgenus' || self.rank_class.rank_name == 'subspecies') && old_parent.name == self.name
        errors.add(:parent_id, "The nominotypical #{self.rank_class.rank_name} #{self.name} could not be moved out of the nominal #{old_parent.rank_class.rank_name}")
      end
    end
  end

  def validate_source_type
    if self.source
      errors.add(:source_id, 'Source must be a Bibtex') if self.source.type != 'Source::Bibtex'
    end
  end

  #TODO: validate, that all the ranks in the table could be linked to ranks in classes (if those had changed)

  #endregion

  #region Soft validation

  def sv_missing_fields
    soft_validations.add(:source_id, 'Source is missing') if self.source_id.nil?
    soft_validations.add(:verbatim_author, 'Author is missing',
                         fix: :sv_fix_missing_author,
                         success_message: 'Year was updated') if self.verbatim_author.blank?
    soft_validations.add(:year_of_publication, 'Year is missing',
                         fix: :sv_fix_missing_year,
                         success_message: 'Year was updated') if self.year_of_publication.nil?
  end

  def sv_fix_missing_author
    if self.source_id
      unless self.source.author.blank?
        self.verbatim_author = self.source.author
        begin
          TaxonName.transaction do
            self.save
            return true
          end
        rescue
          return false
        end
      end
    end
    false
  end

  def sv_fix_missing_year
    if self.source_id
      if self.source.year
        self.year_of_publication = self.source.year
        begin
          TaxonName.transaction do
            self.save
            return true
          end
        rescue
          return false
        end
      end
    end
    false
  end

  def sv_parent_is_valid_name
    if self.parent.unavailable_or_invalid?
      # parent of a taxon is unavailable or invalid
      soft_validations.add(:parent_id, 'Parent should be a valid taxon',
                           fix: :sv_fix_parent_is_valid_name,
                           success_message: 'Parent was updated')
      else
        classifications = self.taxon_name_classifications
        classification_names = classifications.map{|i| i.type_name}
        compare = TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID & classification_names
        unless compare.empty?
          unless Protonym.with_parent_taxon_name(self).without_taxon_name_classification_array(TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID).empty?
            compare.each do |i|
              # taxon is unavailable or invalid, but have valid children
              soft_validations.add(:base, "Taxon has a status ('#{i.constantize.class_name}') conflicting with presence of subordinate taxa")
            end
          end
        end
    end
  end

  def sv_fix_parent_is_valid_name
    if self.parent.unavailable_or_invalid?
      new_parent = self.parent.get_valid_taxon_name
      if self.parent != new_parent
        self.parent = new_parent
        begin
          TaxonName.transaction do
            self.save
            return true
          end
        rescue
        end
      end
    end
    false
  end

  def sv_validate_parent_rank
    true  # see validation in Protonym.rb
  end

  def sv_missing_relationships
    true  # see validation in Protonym.rb
  end

  def sv_source_older_then_description
    true  # see validation in Protonym.rb and Combination.rb
  end

  def sv_validate_coordinated_names
    true  # see validation in Protonym.rb
  end

  def sv_type_placement
    true  # see validation in Protonym.rb
  end

  def sv_single_sub_taxon
    true # see validation in Protonym.rb
  end

#endregion

end


