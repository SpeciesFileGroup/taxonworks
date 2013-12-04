
class TaxonName < ActiveRecord::Base

  include Housekeeping
  include Shared::Identifiable
  include Shared::Citable

  acts_as_nested_set

  belongs_to :source 
  has_many :taxon_name_relationships, foreign_key: :subject_taxon_name_id
  has_many :related_taxon_name_relationships, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

  has_many :taxon_name_author_roles, class_name: 'TaxonNameAuthor', as: :role_object
  has_many :taxon_name_authors, through: :taxon_name_author_roles, source: :person

  include SoftValidation
  soft_validate(:sv_missing_fields)
  soft_validate(:sv_missing_relationships)
  soft_validate(:sv_validate_parent_rank)

  def all_taxon_name_relationships
    # (self.taxon_name_relationships & self.related_taxon_name_relationships)

    # !! If self relatinships are every made possiblepossible this needs a DISTINCT clause
    TaxonNameRelationship.find_by_sql("SELECT `taxon_name_relationships`.* FROM `taxon_name_relationships` WHERE `taxon_name_relationships`.`subject_taxon_name_id` = #{self.id} UNION
                         SELECT `taxon_name_relationships`.* FROM `taxon_name_relationships` WHERE `taxon_name_relationships`.`object_taxon_name_id` = #{self.id}")
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

  validates_presence_of :type
  validates_presence_of :rank_class, if: Proc.new { |tn| [Protonym].include?(tn.class)}
  validates_presence_of :name, if: Proc.new { |tn| [Protonym].include?(tn.class)}

  before_validation :set_type_if_empty,
    :check_format_of_name,
    :validate_rank_class_class,
    :validate_source_type,
    :validate_parent_rank_is_higher

  before_validation :set_cached_name,
    :set_cached_author_year,
    :set_cached_higher_classification

  def rank
    ::RANKS.include?(self.rank_class) ? self.rank_class.rank_name : nil
  end

  def rank_class=(value)
    write_attribute(:rank_class, value.to_s)
  end

  def rank_class
    r = read_attribute(:rank_class)
    Ranks.valid?(r) ? r.constantize : r 
  end

  def ancestor_at_rank(rank)
    r = Ranks.lookup(self.rank_class.nomenclatural_code, rank)
    return RANKS.index(r) >= RANKS.index(self.rank_class) ? nil :
      self.ancestors.detect { |ancestor| ancestor.rank_class == r }
  end

  protected 

  def set_type_if_empty
    self.type = 'Protonym' if self.type.nil?
  end

  #region Set cached fields

  def set_cached_name
    # see config/initializers/ranks for GENUS_AND_SPECIES_RANKS
    if !GENUS_AND_SPECIES_RANKS_NAMES.include?(self.rank_class.to_s)
      cached_name = nil
    else
      genus = ''
      subgenus = ''
      species = ''
      cached_name = nil
      (self.ancestors + [self]).each do |i|
        if GENUS_AND_SPECIES_RANKS_NAMES.include?(i.rank_class.to_s)
          case i.rank
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
    hc = self.self_and_ancestors.select{|i| FAMILY_AND_ABOVE_RANKS_NAMES.include?(i.rank_class.to_s)}.collect{|i| i.name}.join(':')
    self.cached_higher_classification = hc
  end

  #endregion

  #region Validation

  def validate_parent_rank_is_higher
    if self.rank_class == NomenclaturalRank
      true
    elsif self.parent.nil?
      errors.add(:parent_id, 'A parent is not selected')
    elsif self.type == 'Combination' || self.parent.rank_class == NomenclaturalRank
      true
    elsif RANKS.index(self.rank_class) <= RANKS.index(self.parent.rank_class)
      errors.add(:parent_id, "The parent rank (#{self.parent.rank_class.rank_name}) is not higher than #{self.rank_class.rank_name}")
    elsif !self.children.empty?
      if RANKS.index(self.rank_class) >= self.children.collect{|r| RANKS.index(r.rank_class)}.max
        errors.add(:rank_class, "The taxon rank (#{self.rank_class.rank_name}) is not higher than child ranks")
      end
    end
  end

  def validate_rank_class_class
    if self.type == 'Combination'
      errors.add(:rank_class, "Combination should not have rank") if self.rank_class
    elsif self.type == 'Protonym'
      if !Ranks.valid?(rank_class)
        errors.add(:rank_class, "Rank not found")
      end
    end
  end

  def validate_source_type
    if self.source
      errors.add(:source_id, "Source must be a Bibtex") if self.source.type != 'Source::Bibtex'
    end
  end

  def check_format_of_name
    if self.rank_class && self.rank_class.respond_to?(:validate_name_format)
      self.rank_class.validate_name_format(self)
    end
  end

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
      if !self.source.author.blank?
        self.verbatim_author = self.source.author
      end
    end
  end

  def sv_fix_missing_year
    if self.source_id
      if self.source.year
        self.year_of_publication = self.source.year
      end
    end
  end

  def sv_missing_relationships
    if SPECIES_RANKS_NAMES.include?(self.rank_class.to_s)
      soft_validations.add(:base, 'Original genus is missing') if self.original_combination_genus.nil?
    end
  end

  def sv_validate_parent_rank
    if self.type == 'Combination' || self.rank_class.to_s == 'NomenclaturalRank'
      true
    elsif self.parent.rank_class.to_s == 'NomenclaturalRank'
      true
    elsif !self.rank_class.valid_parents.include?(self.parent.rank_class.to_s)
      soft_validations.add(:rank_class, "The rank #{self.rank_class.rank_name} is not compatible with the rank of parent (#{self.parent.rank_class.rank_name})")
    end
  end

  def sv_source_older_then_description
    true
  end

  #endregion

end


