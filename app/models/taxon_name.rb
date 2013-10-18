class TaxonName < ActiveRecord::Base

  include Shared::Identifiable
  include Shared::Citable

  acts_as_nested_set

  belongs_to :source 
  has_many :taxon_name_relationships, foreign_key: :subject_taxon_name_id
  has_many :related_taxon_name_relationships, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

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

  # TODO: validates_format_of :name, with: "something", if: "some proc"

  before_validation :set_type_if_empty,
                    :check_format_of_name,
                    :validate_rank_class_class,
                    :validate_source_type,
                    :validate_parent_rank_is_higher

  after_validation :set_cached_name,
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

  # TODO: This should be based on the logic of the related Rank
  def set_cached_name
    genus_species_ranks = NomenclaturalRank::Iczn::GenusGroup.descendants + NomenclaturalRank::Iczn::SpeciesGroup.descendants + NomenclaturalRank::Icn::GenusGroup.descendants + [NomenclaturalRank::Icn::Species] + NomenclaturalRank::Icn::InfraspecificGroup.descendants
    if !genus_species_ranks.include?(self.rank_class)
      name = nil
    else
      genus = ''
      subgenus = ''
      species = ''
      (self.ancestors + [self]).each do |i|

        if genus_species_ranks.include?(Object.const_get(self.rank_class.to_s))
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
          subgenus = '(' + subgenus.strip! + ') ' unless subgenus.empty?
        end
      end
      name = (genus + subgenus + species).strip!
    end
    self.cached_name = name
  end

  def set_cached_author_year
    begin
      rank = self.rank_class.to_class
    rescue NameError
      rank = nil
    end

    if rank.nil?
      ay = ([self.verbatim_author.to_s] + [self.year_of_publication]).compact.join(', ')
    else
      if rank.nomenclatural_code == :iczn
        ay = ([self.verbatim_author.to_s] + [self.year_of_publication.to_s]).compact.join(', ')
        if NomenclaturalRank::Iczn::SpeciesGroup.ancestors.include?(self.rank_class)
          if self.original_combination_genus.name != self.ancestor_at_rank('genus').name and !self.original_combination_genus.name.to_s.empty?
            ay = '(' + ay + ')' unless ay.empty?
          end
       end
      elsif rank.nomenclatural_code == :icn
        t = [self.verbatim_author.to_s]
        t += ['(' + self.year_of_publication.to_s + ')'] unless self.year_of_publication.nil?
        ay = t.compact.join(' ')
      else
        ay = ([self.verbatim_author.to_s] + [self.year_of_publication]).compact.join(', ')
      end
    end
    self.cached_author_year = ay
  end

  def set_cached_higher_classification
    above_family_ranks = NomenclaturalRank::Iczn::AboveFamilyGroup.descendants + NomenclaturalRank::Iczn::FamilyGroup.descendants + NomenclaturalRank::Icn::AboveFamilyGroup.descendants + NomenclaturalRank::Icn::FamilyGroup.descendants
    hc = self.ancestors.select{|i| [i.rank_class] == [i.rank_class] & above_family_ranks}.collect{|i| i.name}.join(':')
    self.cached_higher_classification = hc
  end


  def validate_parent_rank_is_higher
    return true if self.parent.nil? || self.parent.rank_class == NomenclaturalRank
    if RANKS.index(self.rank_class) < RANKS.index(self.parent.rank_class)
      errors.add(:parent_id, "parent rank (#{self.parent.rank_class.rank_name}) is not higher than #{self.rank_class.rank_name}")
    end
  end

  def validate_source_type
    if !self.source.nil?
      errors.add(:source_id, "source must be a Bibtex") if self.source.type != 'Source::Bibtex'
    end
  end

  def validate_rank_class_class
    # TODO: refactor properly
    return true if self.class == Combination && self.rank_class.nil?
    errors.add(:rank_class, "rank not found") if !Ranks.valid?(rank_class)
  end

  def check_format_of_name
    if self.rank_class && self.rank_class.respond_to?(:validate_name_format)
      self.rank_class.validate_name_format(self)
    end
  end

end


