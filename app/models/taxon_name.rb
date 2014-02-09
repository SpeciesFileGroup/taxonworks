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

  validates_presence_of :type, message: 'Type is not specified'
  validates_presence_of :rank_class, message: 'Rank is a required field', if: Proc.new { |tn| [Protonym].include?(tn.class)}
  validates_presence_of :name, message: 'Name is a required field', if: Proc.new { |tn| [Protonym].include?(tn.class)}

  before_validation :set_type_if_empty,
                    :check_format_of_name,
                    :validate_rank_class_class,
                    :validate_parent_rank_is_higher,
                    :validate_parent_is_set,
                    :check_new_rank_class,
                    :check_new_parent_class,
                    :validate_source_type,
                    :set_cached_names

  soft_validate(:sv_validate_name, set: :validate_name)
  soft_validate(:sv_missing_fields, set: :missing_fields)
  soft_validate(:sv_parent_is_valid_name, set: :parent_is_valid_name)
  soft_validate(:sv_source_older_then_description, set: :source_older_then_description)
  soft_validate(:sv_cached_names, set: :cached_names)

  def all_taxon_name_relationships
    # (self.taxon_name_relationships & self.related_taxon_name_relationships)

    # !! If self relatinships are every made possiblepossible this needs a DISTINCT clause
    TaxonNameRelationship.find_by_sql("SELECT taxon_name_relationships.* FROM taxon_name_relationships WHERE taxon_name_relationships.subject_taxon_name_id = #{self.id} UNION
                         SELECT taxon_name_relationships.* FROM taxon_name_relationships WHERE taxon_name_relationships.object_taxon_name_id = #{self.id}")
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
    Ranks.valid?(r) ? r.safe_constantize : r
  end

  def nomenclature_date
    return nil if self.id.nil?
    family_before_1961 = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_string('TaxonNameRelationship::Iczn::PotentiallyValidating::FamilyBefore1961').first
    if family_before_1961.nil?
      year = self.year_of_publication ? Time.utc(self.year_of_publication, 12, 31) : nil
      self.source ? (self.source.nomenclature_date ? self.source.nomenclature_date.to_time : year) : year
    else
      obj = family_before_1961.object_taxon_name
      year = obj.year_of_publication ? Time.utc(obj.year_of_publication, 12, 31) : nil
      obj.source ? (self.source.nomenclature_date ? obj.source.nomenclature_date.to_time : year) : year
    end
  end

  def cached_name_and_author_year
    if self.rank_class.to_s =~ /::(Species|Genus)/
      (self.cached_name.to_s + ' ' + self.cached_author_year.to_s).squish!
    else
      (self.name.to_s + ' ' + self.cached_author_year.to_s).squish!
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

  def get_valid_taxon_name # get valid name for any taxon
    vn = TaxonNameRelationship.where_subject_is_taxon_name(self).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID)
    (vn.count == 1) ? vn.first.object_taxon_name : self
  end

  def name_with_alternative_spelling
    if self.type.to_s != 'Protonym' || self.rank_class.nil? || self.rank_class.to_s =~ /::Icn::/
      return nil
    elsif self.rank_class.to_s =~ /Species/
      n = self.name.squish # remove extra spaces and line brakes
      n = n.split(' ').last
      n = n[0..-4] + 'ae' if n =~ /^[a-z]*iae$/        # iae > ae in the end of word
      n = n[0..-6] + 'orum' if n =~ /^[a-z]*iorum$/    # iorum > orum
      n = n[0..-6] + 'arum' if n =~ /^[a-z]*iarum$/    # iarum > arum
      n = n[0..-3] + 'a' if n =~ /^[a-z]*um$/          # um > a
      n = n[0..-3] + 'a' if n =~ /^[a-z]*us$/          # us > a
      n = n[0..-7] + 'ensis' if n =~ /^[a-z]*iensis$/  # iensis > ensis
      n = n[0..-5] + 'ana' if n =~ /^[a-z]*self.rank_classiana$/      # iensis > ensis
      n = n.gsub('ae', 'e').
          gsub('oe', 'e').
          gsub('ai', 'i').
          gsub('ei', 'i').
          gsub('ej', 'i').
          gsub('ii', 'i').
          gsub('ij', 'i').
          gsub('jj', 'i').
          gsub('j', 'i').
          gsub('y', 'i').
          gsub('v', 'u').
          gsub('rh', 'r').
          gsub('th', 't').
          gsub('k', 'c').
          gsub('ch', 'c').
          gsub('tt', 't').
          gsub('bb', 'b').
          gsub('rr', 'r').
          gsub('nn', 'n').
          gsub('mm', 'm').
          gsub('pp', 'p').
          gsub('ss', 's').
          gsub('ff', 'f').
          gsub('ll', 'l').
          gsub('ct', 't').
          gsub('ph', 'f').
          gsub('-', '')
      n = n[0, 3] + n[3..-4].gsub('o', 'i') + n[-3, 3] if n.length > 6  # connecting vowel in the middle of the word (nigrocinctus vs. nigricinctus)
    elsif self.rank_class.to_s =~ /Family/
      n = Protonym.family_group_base(self.name) + 'idae'
    else
      n = self.name.squish
    end
    return n
  end


  #region Set cached fields

  def set_type_if_empty
    self.type = 'Protonym' if self.type.nil?
  end

  def set_cached_names
    # if updated, update also sv_cached_names
    set_cached_full_name
    set_cached_original_combination
    set_cached_author_year
    if self.class.to_s == 'Protonym'
      set_cached_higher_classification
      set_primaty_homonym
      set_primary_homonym_alt
      if self.rank_class.to_s =~ /Species/
        set_secondary_homonym
        set_secondary_homonym_alt
      end
    end
  end

  def set_cached_full_name
    if self.class.to_s == 'Combination'
      self.cached_name = get_combination
    elsif self.class.to_s == 'Protonym'
      self.cached_name = get_full_name
    end
  end

  def set_cached_original_combination
    if self.class.to_s == 'Combination'
      self.cached_original_combination = get_combination
    elsif self.class.to_s == 'Protonym'
      self.cached_original_combination = get_original_combination
    end
  end

  def set_cached_author_year
    self.cached_author_year = get_author_and_year
  end

  def set_cached_higher_classification
    self.cached_higher_classification = get_higher_classification
  end

  def set_primaty_homonym
    self.cached_primary_homonym = get_genus_species(:original, :self)
  end

  def set_primary_homonym_alt
    self.cached_primary_homonym_alt = get_genus_species(:original, :alternative)
  end

  def set_secondary_homonym
    self.cached_secondary_homonym = get_genus_species(:curent, :self)
  end

  def set_secondary_homonym_alt
    self.cached_secondary_homonym_alt = get_genus_species(:curent, :alternative)
  end

  def get_full_name
    # see config/initializers/ranks for GENUS_AND_SPECIES_RANKS
    unless GENUS_AND_SPECIES_RANK_NAMES.include?(self.rank_class.to_s)
      cached_name = nil
    else
      genus = ''
      subgenus = ''
      superspecies = ''
      species = ''
      (self.ancestors + [self]).each do |i|
        if GENUS_AND_SPECIES_RANK_NAMES.include?(i.rank_class.to_s)
          case i.rank_class.rank_name
            when 'genus' then genus = '<em>' + i.name + '</em> '
            when 'subgenus' then subgenus += '<em>' + i.name + '</em> '
            when 'section' then subgenus += 'sect. <em>' + i.name + '</em> '
            when 'subsection' then subgenus += 'subsect. <em>' + i.name + '</em> '
            when 'series' then subgenus += 'ser. <em>' + i.name + '</em> '
            when 'subseries' then subgenus += 'subser. <em>' + i.name + '</em> '
            when 'species group' then superspecies += '<em>' + i.name + '</em> '
            when 'species' then species += '<em>' + i.name + '</em> '
            when 'subspecies' then species += '<em>' + i.name + '</em> '
            when 'variety' then species += 'var. <em>' + i.name + '</em> '
            when 'subvariety' then species += 'subvar. <em>' + i.name + '</em> '
            when 'form' then species += 'f. <em>' + i.name + '</em> '
            when 'subform' then species += 'subf. <em>' + i.name + '</em> '
            else
          end
        end
      end
      subgenus = '(' + subgenus.squish + ') ' unless subgenus.empty?
      superspecies = '(' + superspecies.squish + ') ' unless superspecies.empty?
      cached_name = (genus + subgenus + superspecies + species).squish.gsub('</em> <em>', ' ')
    end
  end

  def get_original_combination
    unless GENUS_AND_SPECIES_RANK_NAMES.include?(self.rank_class.to_s) && self.class == Protonym
      cached_name = nil
    else
      relationships = self.original_combination_relationships
      relationships.sort!{|r| r.type_class.order_index}
      genus = ''
      subgenus = ''
      superspecies = ''
      species = ''
      relationships.each do |i|
        case i.type_class.object_relationship_name
          when 'original genus' then genus = '<em>' + i.subject_taxon_name.name + '</em> '
          when 'original subgenus' then subgenus += '<em>' + i.subject_taxon_name.name + '</em> '
          when 'original section' then subgenus += 'sect. <em>' + i.subject_taxon_name.name + '</em> '
          when 'original subsection' then subgenus += 'subsect. <em>' + i.subject_taxon_name.name + '</em> '
          when 'original series' then subgenus += 'ser. <em>' + i.subject_taxon_name.name + '</em> '
          when 'original subseries' then subgenus += 'subser. <em>' + i.subject_taxon_name.name + '</em> '
          when 'original species' then species += '<em>' + i.subject_taxon_name.name + '</em> '
          when 'original subspecies' then species += '<em>' + i.subject_taxon_name.name + '</em> '
          when 'original variety' then species += 'var. <em>' + i.subject_taxon_name.name + '</em> '
          when 'original subvariety' then species += 'subvar. <em>' + i.subject_taxon_name.name + '</em> '
          when 'original form' then species += 'f. <em>' + i.subject_taxon_name.name + '</em> '
          else
        end
      end
      if self.rank_class.to_s =~ /Genus/
        if genus.blank?
          genus += '<em>' + self.name + '</em> '
        else
          subgenus += '<em>' + self.name + '</em> '
        end
      elsif self.rank_class.to_s =~ /Species/
        species += '<em>' + self.name + '</em> '
        genus = '<em>' + self.ancestor_at_rank('genus').name + '</em> ' if genus.empty? && !self.ancestor_at_rank('genus').nil?
      end
      subgenus = '(' + subgenus.squish + ') ' unless subgenus.empty?
      cached_name = (genus + subgenus + superspecies + species).squish.gsub('</em> <em>', ' ')
    end
  end

  def get_combination
    unless self.class == Combination
      cached_name = nil
    else
      relationships = self.combination_relationships
      relationships.sort!{|r| r.type_class.order_index}
      genus = ''
      subgenus = ''
      superspecies = ''
      species = ''
      relationships.each do |i|
        case i.type_class.object_relationship_name
          when 'genus' then genus = '<em>' + i.subject_taxon_name.name + '</em> '
          when 'subgenus' then subgenus += '<em>' + i.subject_taxon_name.name + '</em> '
          when 'section' then subgenus += 'sect. <em>' + i.subject_taxon_name.name + '</em> '
          when 'subsection' then subgenus += 'subsect. <em>' + i.subject_taxon_name.name + '</em> '
          when 'series' then subgenus += 'ser. <em>' + i.subject_taxon_name.name + '</em> '
          when 'subseries' then subgenus += 'subser. <em>' + i.subject_taxon_name.name + '</em> '
          when 'species' then species += '<em>' + i.subject_taxon_name.name + '</em> '
          when 'subspecies' then species += '<em>' + i.subject_taxon_name.name + '</em> '
          when 'variety' then species += 'var. <em>' + i.subject_taxon_name.name + '</em> '
          when 'subvariety' then species += 'subvar. <em>' + i.subject_taxon_name.name + '</em> '
          when 'form' then species += 'f. <em>' + i.subject_taxon_name.name + '</em> '
          when 'subform' then species += 'subf. <em>' + i.subject_taxon_name.name + '</em> '
          else
        end
      end

      parent_rank = self.parent.rank_class.to_s
      if parent_rank =~ /Genus/
        if genus.blank?
          genus += '<em>' + self.parent.name + '</em> '
        else # if  self.('combination_' + self.parent.rank_class.rank_name).to_sym.nil?
          subgenus += '<em>' + self.parent.name + '</em> '
        end
      elsif parent_rank =~ /Species/
        species += '<em>' + self.parent.name + '</em> ' # if self.('combination_' + self.parent.rank_class.rank_name).to_sym.nil?
      end
      subgenus = '(' + subgenus.squish + ') ' unless subgenus.empty?
      cached_name = (genus + subgenus + superspecies + species).squish.gsub('</em> <em>', ' ')
    end
  end

  def get_genus_species(genus_option, self_option)
    genus = nil
    name1 = nil
    if self.rank_class.nil?
      return nil
    elsif genus_option == :original
      genus = self.original_genus
    elsif genus_option == :curent
      genus = self.ancestor_at_rank('genus')
    end
    genus = genus.name unless genus.blank?

    if self.rank_class.to_s =~ /Species/ && genus.blank?
      return nil
    elsif self_option == :self
      name1 = self.name
    elsif self_option == :alternative
      name1 = self.name_with_alternative_spelling
    end
    (genus.to_s + ' ' + name1.to_s).squish
  end

  #TODO: check homotypic synonyms

  def get_author_and_year
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
    ay
  end

  def get_higher_classification
    # see config/initializers/ranks for FAMILY_AND_ABOVE_RANKS
    (self.ancestors + [self]).select{|i| FAMILY_AND_ABOVE_RANK_NAMES.include?(i.rank_class.to_s)}.collect{|i| i.name}.join(':')
  end

  #endregion

  protected

  #region Validation

  def validate_parent_is_set
    if !(self.rank_class == NomenclaturalRank) && !(self.type == 'Combination')
      errors.add(:parent_id, 'A parent is not selected') if self.parent_id.blank?
    end
  end

  def check_format_of_name
    if self.rank_class && self.rank_class.respond_to?(:validate_name_format)
      self.rank_class.validate_name_format(self)
    end
  end

  def validate_parent_rank_is_higher
    if self.parent && !self.rank_class.blank? && self.rank_class != NomenclaturalRank
      if RANKS.index(self.rank_class) <= RANKS.index(self.parent.rank_class)
        errors.add(:parent_id, "The parent rank (#{self.parent.rank_class.rank_name}) is not higher than #{self.rank_class.rank_name}")
      end

      if (self.rank_class != self.rank_class_was) && self.children && !self.children.empty? && RANKS.index(self.rank_class) >= self.children.collect{|r| RANKS.index(r.rank_class)}.max
        errors.add(:rank_class, "The taxon rank (#{self.rank_class.rank_name}) is not higher than child ranks")
      end
    end 
  end

  def validate_rank_class_class
    if self.type == 'Combination'
      errors.add(:rank_class, 'Combination should not have rank') if !!self.rank_class
    elsif self.type == 'Protonym'
      errors.add(:rank_class, 'Rank not found') unless Ranks.valid?(rank_class)
    end
  end

  def check_new_rank_class
    if self.rank_class != self.rank_class_was && !self.rank_class_was.nil?
      old_rank_group = self.rank_class_was.safe_constantize.parent
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

  def sv_validate_name
    if self.name =~ /^[a-zA-Z]*$/
      correct_name_format = true
    elsif self.rank_class.nomenclatural_code == :iczn && self.name =~ /^[a-zA-Z]-[a-zA-Z]*$/
      correct_name_format = true
    elsif self.rank_class.nomenclatural_code == :icn && self.name =~ /^[a-zA-Z]*-[a-zA-Z]*$/
      correct_name_format = true
    elsif self.rank_class.nomenclatural_code == :icn && self.name =~ /^[a-zA-Z]*\s×\s[a-zA-Z]*$/
      correct_name_format = true
    elsif self.rank_class.nomenclatural_code == :icn && self.name =~ /^×\s[a-zA-Z]*$/
      correct_name_format = true
    else
      correct_name_format = false
    end

    unless correct_name_format
      invalid_statuses = TAXON_NAME_CLASS_NAMES_UNAVAILABLE_AND_INVALID
      invalid_statuses = invalid_statuses & self.taxon_name_classifications.collect{|c| c.type_class.to_s}
      misspellings = TaxonNameRelationship.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling,
                                                                 TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling,
                                                                 TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling)
      misspellings = misspellings & self.taxon_name_relationships.collect{|c| c.type_class.to_s}
      if invalid_statuses.empty? && misspellings.empty?
        soft_validations.add(:name, 'Name should not have spaces or special characters, unless it has a status of misspelling')
      end
    end
  end

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
              soft_validations.add(:base, "Taxon has a status ('#{i.safe_constantize.class_name}') conflicting with presence of subordinate taxa")
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

  def sv_cached_names
    # if updated, update also set_cached_names
    cached = true
    if self.cached_author_year != get_author_and_year
      cached = false
    elsif self.class.to_s == 'Protonym'
      if self.cached_name != get_full_name || self.cached_original_combination != get_original_combination || self.cached_higher_classification != get_higher_classification || self.cached_primary_homonym != get_genus_species(:original, :self) || self.cached_primary_homonym_alt != get_genus_species(:original, :alternative)
        cached = false
      elsif self.rank_class.to_s =~ /Species/
        if self.cached_secondary_homonym != get_genus_species(:curent, :self) || self.cached_secondary_homonym_alt != get_genus_species(:curent, :alternative)
          cached = false
        end
      end
    elsif self.class.to_s == 'Combination'
      if self.cached_name != get_combination || self.cached_original_combination != get_combination
        cached = false
      end
    end
    unless cached
      soft_validations.add(:base, 'Cached values should be updated',
                           fix: :sv_fix_cached_names, success_message: 'Cached values were updated')
    end
  end

  def sv_fix_cached_names
    begin
      TaxonName.transaction do
        self.save
        return true
      end
    rescue
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

  def sv_parent_priority
    true # see validation in Protonym.rb
  end

  def sv_homotypic_synonyms
    true # see validation in Protonym.rb
  end

  def sv_potential_homonyms
    true # see validation in Protonym.rb
  end


#endregion

end


