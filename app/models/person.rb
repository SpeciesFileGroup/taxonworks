# A human. Data only, not users. There are two classes of people: vetted and unvetted.
# !! People are only related to data via Roles.
#
# A vetted person
# * Has two or more roles
# * Has one or more annotations
#
# An unvetted person
# * Has no or 1 role
# * Has no annotations
#
# A unvetted person becomes automatically vetted when they have > 1 roles or they
# have an annotation associated with them.
#
# @!attribute type
#   @return [String]
#   Person::Vetted or Person::Unvetted
#
# @!attribute last_name
#   @return [String]
#   the last/family name
#
# @!attribute first name
#   @return [String]
#   the first name, includes initials if the are provided
#
# @!attribute suffix
#   @return [String]
#   string following the *last/family* name
#
# @!attribute year_active_start
#   @return [Integer]
#     (rough) starting point of when person made scientific assertions that were dissemenated (i.e. could be seen by others)
#
# @!attribute year_active_end
#   @return [Integer]
#     (rough) ending point of when person made scientific assertions that were dissemenated (i.e. could be seen by others)
#
# @!attribute year_born
#   @return [Integer]
#     born on
#
## @!attribute year_died
#   @return [Integer]
#     year died
#
# @!attribute cached
#   @return [String]
#      full name
#
class Person < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::AlternateValues
  include Shared::DataAttributes
  include Shared::Identifiers
  include Shared::Notes
  include Shared::SharedAcrossProjects
  include Shared::HasPapertrail
  include Shared::IsData

  ALTERNATE_VALUES_FOR = [:last_name, :first_name].freeze
  IGNORE_SIMILAR       = [:type, :cached].freeze
  IGNORE_IDENTICAL     = [:type, :first_name, :last_name, :prefix, :suffix].freeze

  # @return [Boolean]
  #   true when cached values have not been built
  attr_accessor :no_cached

  validates_presence_of :last_name, :type

  validates :year_born, inclusion: {in: 0..Time.now.year}, allow_nil: true
  validates :year_died, inclusion: {in: 0..Time.now.year}, allow_nil: true
  validates :year_active_start, inclusion: {in: 0..Time.now.year}, allow_nil: true
  validates :year_active_end, inclusion: {in: 0..Time.now.year}, allow_nil: true

  validate :died_after_born
  validate :activity_ended_after_started
  validate :not_active_after_death
  validate :not_active_before_birth
  validate :not_gandalf

  before_validation :set_type_if_blank

  after_save :set_cached, unless: Proc.new { |n| n.no_cached || errors.any? }

  validates :type, inclusion: {
    in:      ['Person::Vetted', 'Person::Unvetted'],
    message: '%{value} is not a validly_published type'}

  has_many :roles, dependent: :destroy, inverse_of: :person
  has_many :author_roles, class_name: 'SourceAuthor'
  has_many :editor_roles, class_name: 'SourceEditor'
  has_many :source_roles, class_name: 'SourceSource'
  has_many :collector_roles, class_name: 'Collector'
  has_many :determiner_roles, class_name: 'Determiner'
  has_many :taxon_name_author_roles, class_name: 'TaxonNameAuthor'
  has_many :type_designator_roles, class_name: 'TypeDesignator'
  has_many :georeferencer_roles, class_name: 'Georeferencer'

  # has_many :sources, through: :roles   # TODO: test and confirm dependent

  has_many :authored_sources, through: :author_roles, source: :role_object, source_type: 'Source::Bibtex'
  has_many :edited_sources, through: :editor_roles, source: :role_object, source_type: 'Source::Bibtex'
  has_many :human_sources, through: :source_roles, source: :role_object, source_type: 'Source::Human'
  has_many :collecting_events, through: :collector_roles, source: :role_object, source_type: 'CollectingEvent'
  has_many :taxon_determinations, through: :determiner_roles, source: :role_object, source_type: 'TaxonDetermination'
  has_many :authored_taxon_names, through: :taxon_name_author_roles, source: :role_object, source_type: 'TaxonName'
  has_many :type_material, through: :type_designator_roles, source: :role_object, source_type: 'TypeMaterial'
  has_many :georeferences, through: :georeferencer_roles, source: :role_object, source_type: 'Georeference'

  scope :created_before, -> (time) { where('created_at < ?', time) }
  scope :with_role, -> (role) { includes(:roles).where(roles: {type: role}) }
  scope :ordered_by_last_name, -> { order(:last_name) }

  # @return [Boolean]
  #   !! overwrites IsData#is_in_use?
  def is_in_use?
    roles.any?
  end

  # @return [String]
  def name
    [first_name, prefix, last_name, suffix].compact.join(' ')
  end

  # @return [String]
  #   The person's name in BibTeX format (von last, Jr, first)
  def bibtex_name
    out = ''

    out << prefix + ' ' unless prefix.blank?
    out << last_name unless last_name.blank?
    out << ', ' unless out.blank? || (first_name.blank? && suffix.blank?)
    out << suffix unless suffix.blank?

    out << ', ' unless out.end_with?(', ') || first_name.blank? || out.blank?
    out << first_name unless first_name.blank?
    out.strip
  end

  # @return [String]
  #   The person's full last name including prefix & suffix (von last Jr)
  def full_last_name
    [prefix, last_name, suffix].compact.join(' ')
  end

  # @return [Boolean]
  def is_author?
    author_roles.to_a.length > 0
  end

  # @return [Boolean]
  def is_editor?
    editor_roles.to_a.length > 0
  end

  # @return [Boolean]
  def is_source?
    source_roles.to_a.length > 0
  end

  # @return [Boolean]
  def is_collector?
    collector_roles.to_a.length > 0
  end

  # @param [Integer] person_id
  # @return [Boolean]
  #   true if all records updated, false if any one failed (all or none)
  # r_person is merged into l_person (self)
  def merge_with(person_id)
    if r_person = Person.find(person_id) # get the new (merged into self) person
      # r_err         = nil
      begin
        ApplicationRecord.transaction do
          Role.where(person_id: r_person.id).update(person: self) # update merge person's roles to old
          l_person_hash = self.annotations_hash
          # TODO: When names don't match add alternate values to the corresponding names except extant
          if self.first_name != r_person.first_name
            # create a first_name alternate_value of the r_person first name
            skip_av = false
            av_list = l_person_hash['alternate values']
            (av_list ||= {}).each do |av|
              if av.text == r_person.first_name
                if av.type == 'AlternateValue::AlternateSpelling' &&
                  av.alternate_value_object_attribute == 'first_name' # &&
                  # av.project_id == r_person.project_id
                  skip_av = true
                  break # stop looking in this bunch, if you found a match
                end
              end
            end

            AlternateValue::AlternateSpelling.create(alternate_value_object_type:      'Person',
                                                     value:                            r_person.first_name,
                                                     alternate_value_object_attribute: 'first_name',
                                                     alternate_value_object_id:        id) unless skip_av
          end
          if self.last_name != r_person.last_name
            # create a last_name alternate_value of the r_person first name
            skip_av = false
            av_list = l_person_hash['alternate values']
            (av_list ||= {}).each do |av|
              if av.text == r_person.last_name
                if av.type == 'AlternateValue::AlternateSpelling' &&
                  av.alternate_value_object_attribute == 'last_name' # &&
                  # av.project_id == r_person.project_id
                  skip_av = true
                  break # stop looking in this bunch, if you found a match
                end
              end
            end

            AlternateValue::AlternateSpelling.create(alternate_value_object_type:      'Person',
                                                     value:                            r_person.last_name,
                                                     alternate_value_object_attribute: 'last_name',
                                                     alternate_value_object_id:        id) unless skip_av
          end
          r_person.annotations_hash.each do |r_kee, r_objects|
            r_objects.each do |r_o|
              skip   = false
              l_test = l_person_hash[r_kee]
              if l_test.present?
                l_test.each do |l_o| # only look at same-type annotations
                  # four types of annotations:
                  # # data attributes,
                  # # identifiers,
                  # # notes,
                  # # alternate values
                  case r_kee
                    when 'data attributes'
                      if l_o.type == r_o.type &&
                        l_o.controlled_vocabulary_term_id == r_o.controlled_vocabulary_term_id &&
                        l_o.value == r_o.value &&
                        l_o.project_id == r_o.project_id
                        skip = true
                        break # stop looking in this bunch, if you found a match
                      end
                    when 'identifiers'
                      if l_o.type == r_o.type &&
                        l_o.identifier == r_o.identifier &&
                        l_o.project_id == r_o.project_id
                        skip = true
                        break # stop looking in this bunch, if you found a match
                      end
                    when 'notes'
                      if l_o.text == r_o.text &&
                        l_o.note_object_attribute == r_o.note.object_attribute &&
                        l_o.project_id == r_o.project_id
                        skip = true
                        break # stop looking in this bunch, if you found a match
                      end
                    when 'alternate values'
                      if l_o.value == r_o.value
                        if l_o.type == r_o.type &&
                          l_o.alternate_value_object_attribute == r_o.alternate_value_object_attribute &&
                          l_o.project_id == r_o.project_id
                          skip = true
                          break # stop looking in this bunch, if you found a match
                        end
                      end
                  end
                end
                skip
              end
              unless skip
                # r_err                = r_o
                r_o.annotated_object = self
                r_o.save!
                # r_o
              end
            end
          end
          # TODO: handle years attributes
          if self.year_born.nil?
            self.year_born = r_person.year_born
          else
            #
          end
          if self.year_died.nil?
            self.year_died = r_person.year_died
          else
            #
          end
          if r_person.year_active_start # if not, r_person has nothing to contribute
            if self.year_active_start.nil? || (self.year_active_start > r_person.year_active_start)
              self.year_active_start = r_person.year_active_start
            end
          end
          if r_person.year_active_end # if not, r_person has nothing to contribute
            if self.year_active_end.nil? || (self.year_active_end < r_person.year_active_end)
              self.year_active_end = r_person.year_active_end
            end
          end
          # last thing to do in the transaction...
          self.save! unless self.persisted?
        end
      rescue ActiveRecord::RecordInvalid => r_e
        # puts Rainbow("Failed with #{r_e.error.full_messages.join(', ')}.").red
        # puts Rainbow("Failed with #{r_err.errors.messages.join(', ')}.").red
        return false
      end
    end
    true
  end

  # @return [Boolean]
  def is_determiner?
    determiner_roles.to_a.length > 0
  end

  # @return [Boolean]
  def is_taxon_name_author?
    taxon_name_author_roles.to_a.length > 0
  end

  # @return [Boolean]
  def is_type_designator?
    type_designator_roles.to_a.length > 0
  end

  # @return [Boolean]
  def is_georeferencer?
    georeferencer_roles.to_a.length > 0
  end

  # @param [String] name_string
  # @return [Array] of Hashes
  #   use citeproc to parse strings
  def self.parser(name_string)
    BibTeX::Entry.new(type: :book, author: name_string).parse_names.to_citeproc['author']
  end

  # @param [String] name_string
  # @return [Array] of People
  #    return people for name strings
  def self.parse_to_people(name_string)
    parser(name_string).collect { |n| Person::Unvetted.new(last_name:  n['family'],
                                                           first_name: n['given'],
                                                           prefix:     n['non-dropping-particle']) }
  end

=begin
  What is the logic to declare one person 'identical' to another

  Easy tests:
    0) person.id: if this is the same as self.id, must be same record.
                  OR
    1) person.last_name == last_name
                AND
    2) person.first_name == first_name
                AND
      a) person.cached == cached

    3) person.prefix (subsumed by 'cached'?)
    4) person.suffix (subsumed by 'cached'?)

  A little harder:
    5) person.year_born (if both available)
    6) person.year_died (if both available)
    7) person.year_active_start (if both available)
    8) person.year_active_end (if both available)

  More complex:
    9) person.authored_taxon_names is same set as authored_taxon_names
      a) count is the same
                  AND
      b) taxon names match
=end

  # # @param [Person] person to which this instance is to be compared
  # # @return [Boolean]
  # def identical(person)
  #   # same record
  #   retval = (id == person.id)
  #   unless retval
  #     # two different instances of Person
  #     retval = (last_name == person.last_name and first_name == person.first_name and cached == person.cached)
  #     retval = (retval and (year_born == person.year_born and year_died == person.year_died))
  #     retval = (retval and (year_active_start == person.year_active_start and \
  #                           year_active_end == person.year_active_end))
  #
  #     tn_ids  = taxon_name_author_roles.pluck(:role_object_id)
  #     count  = tn_ids.count
  #     retval = (retval and (count == person.taxon_name_author_roles.count))
  #     if retval and (count > 0) # is still true and there are any roles to test
  #       # Boolean of the intersection of two sets of role object ids equals the local list?
  #       retval = (retval and ((tn_ids & person.taxon_name_author_roles.pluck(:role_object_id)) == tn_ids))
  #     end
  #   end
  #   retval
  # end
  #
  # # @param [Person] person to which this instance is to be compared
  # # @return [Boolean]
  # def similar(person)
  #
  # end

  protected

  # @return [Ignored]
  def died_after_born
    errors.add(:year_born, 'is older than died year') if year_born && year_died && year_born > year_died
  end

  # @return [Ignored]
  def activity_ended_after_started
    errors.add(:year_active_start, 'is older than died year') if year_active_start && year_active_end && year_active_start > year_active_end
  end

  # @return [Ignored]
  def not_active_after_death
    errors.add(:year_active_start, 'is older than year of death') if year_active_start && year_died && year_active_start > year_died
    errors.add(:year_active_end, 'is older than year of death') if year_active_end && year_died && year_active_end > year_died
  end

  # @return [Ignored]
  def not_active_before_birth
    errors.add(:year_active_start, 'is younger than than year of birth') if year_active_start && year_born && year_active_start < year_born
    errors.add(:year_active_end, 'is younger than year of birth') if year_active_end && year_born && year_active_end < year_born
  end

  # @return [Ignored]
  def not_gandalf
    errors.add(:base, 'fountain of eternal life does not exist yet') if year_born && year_died && year_died - year_born > 117
  end

  # TODO: deprecate this, always set explicitly
  # @return [Ignored]
  def set_type_if_blank
    self.type = 'Person::Unvetted' if self.type.blank?
  end

  # @return [Ignored]
  def set_cached
    update_column(:cached, bibtex_name)
    set_taxon_name_cached_author_year
  end

  # @return [Ignored]
  def set_taxon_name_cached_author_year
    if saved_change_to_last_name? || saved_change_to_prefix? || saved_change_to_suffix?
      authored_taxon_names.reload.each do |t|
        t.send(:set_cached) # TODO: optimize, perhaps on set_author_year
      end
    end
  end

end

