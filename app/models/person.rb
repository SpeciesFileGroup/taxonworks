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
  include Shared::Depictions
  include Shared::Tags
  include Shared::SharedAcrossProjects
  include Shared::HasPapertrail
  include Shared::IsData
  include Shared::OriginRelationship

  ALTERNATE_VALUES_FOR = [:last_name, :first_name].freeze
  IGNORE_SIMILAR = [:type, :cached].freeze
  IGNORE_IDENTICAL = [:type, :first_name, :last_name, :prefix, :suffix].freeze

  # @return [true, nil]
  #   set as true to prevent caching
  attr_accessor :no_cached

  # @return [true, nil]
  #   set as true to prevent application of NameCase()
  attr_accessor :no_namecase

  validates_presence_of :last_name, :type

  validates :year_born, inclusion: {in: 0..Time.now.year}, allow_nil: true
  validates :year_died, inclusion: {in: 0..Time.now.year}, allow_nil: true
  validates :year_active_start, inclusion: {in: 0..Time.now.year, message: "%{value} is not within the year 0-#{Time.now.year}"}, allow_nil: true
  validates :year_active_end, inclusion: {in: 0..Time.now.year , message: "%{value} is not within the year 0-#{Time.now.year}"}, allow_nil: true
  validate :died_after_born
  validate :activity_ended_after_started
  validate :not_active_after_death
  validate :not_active_before_birth
  validate :not_gandalf
  validate :not_balrog

  before_validation :namecase_names, unless: Proc.new {|n| n.no_namecase }

  # TODO: remove this
  before_validation :set_type_if_blank

  after_save :set_cached, unless: Proc.new { |n| n.no_cached || errors.any? }

  validates :type, inclusion: {
    in: ['Person::Vetted', 'Person::Unvetted'],
    message: '%{value} is not a validly_published type'}

  has_one :user, dependent: :restrict_with_error, inverse_of: :person

  has_many :roles, dependent: :restrict_with_error, inverse_of: :person #, before_remove: :set_cached_for_related

  has_many :author_roles, class_name: 'SourceAuthor', dependent: :restrict_with_error, inverse_of: :person #, before_remove: :set_cached_for_related
  has_many :editor_roles, class_name: 'SourceEditor', dependent: :restrict_with_error, inverse_of: :person
  has_many :source_roles, class_name: 'SourceSource', dependent: :restrict_with_error, inverse_of: :person
  has_many :collector_roles, class_name: 'Collector', dependent: :restrict_with_error, inverse_of: :person
  has_many :determiner_roles, class_name: 'Determiner', dependent: :restrict_with_error, inverse_of: :person
  has_many :taxon_name_author_roles, class_name: 'TaxonNameAuthor', dependent: :restrict_with_error, inverse_of: :person
  has_many :georeferencer_roles, class_name: 'Georeferencer', dependent: :restrict_with_error, inverse_of: :person

  has_many :sources, through: :roles, source: :role_object, source_type: 'Source' # Editor or Author or Person

  has_many :authored_sources, through: :author_roles, source: :role_object, source_type: 'Source'
  has_many :edited_sources, through: :editor_roles, source: :role_object, source_type: 'Source'
  has_many :human_sources, through: :source_roles, source: :role_object, source_type: 'Source'

  has_many :collecting_events, through: :collector_roles, source: :role_object, source_type: 'CollectingEvent', inverse_of: :collectors
  has_many :taxon_determinations, through: :determiner_roles, source: :role_object, source_type: 'TaxonDetermination', inverse_of: :determiners
  has_many :authored_taxon_names, through: :taxon_name_author_roles, source: :role_object, source_type: 'TaxonName', inverse_of: :taxon_name_authors
  has_many :georeferences, through: :georeferencer_roles, source: :role_object, source_type: 'Georeference', inverse_of: :georeferencers

  has_many :collection_objects, through: :collecting_events
  has_many :dwc_occurrences, through: :collection_objects

  scope :created_before, -> (time) { where('created_at < ?', time) }
  scope :with_role, -> (role) { includes(:roles).where(roles: {type: role}) }
  scope :ordered_by_last_name, -> { order(:last_name) }

  scope :used_in_project, -> (project_id) { joins(:roles).where( roles: { project_id: project_id } ) }

  # Apply a "proper" case to all strings
  def namecase_names
    write_attribute(:last_name, NameCase(last_name)) if last_name && will_save_change_to_last_name?
    write_attribute(:first_name, NameCase(first_name)) if first_name && will_save_change_to_first_name?
    write_attribute(:prefix, NameCase(prefix)) if prefix && will_save_change_to_prefix?
    write_attribute(:suffix, NameCase(suffix)) if suffix && will_save_change_to_suffix?
  end

  # @return [Boolean]
  #   !! overwrites IsData#is_in_use?
  def is_in_use?
    roles.reload.any?
  end

  # @return Boolean
  #   whether or not this Person is linked to any data in the project
  def used_in_project?(project_id)
    Role.where(person_id: id, project_id: project_id).any? ||
      Source.joins(:project_sources, :roles).where(roles: {person_id: id}, project_sources: { project_id: project_id }).any?
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

  # Return [String, nil]
  #   convenience, maybe a delegate: candidate
  def orcid
    identifiers.where(type: 'Identifier::Global::Orcid').first&.cached
  end

  # @param [Integer] person_id
  # @return [Boolean]
  #   true if all records updated, false if any one failed (all or none)
  #
  # No person is destroyed, see `hard_merge`.  self is intended to be kept.
  #
  # r_person is merged into l_person (self)
  #
  def merge_with(person_id)
    return false if person_id == id

    if r_person = Person.find(person_id) # get the person to merge to into self
      begin
        ApplicationRecord.transaction do
          # !! Role.where(person_id: r_person.id).update(person_id: id) is BAAAD
          # !! It appends person_id: <old> to Role.where() in callbacks, breaking
          # !! Role#vet_person, etc.
          # update merge person's roles to old
          Role.where(person_id: r_person.id).each do |r|
            return false unless r.update(person_id: id)
          end

          roles.reload

          l_person_hash = annotations_hash

          unless r_person.first_name.blank?
            if first_name.blank?
              update(first_name: r_person.first_name)
            else
              if first_name != r_person.first_name
                # create a first_name alternate_value of the r_person first name
                skip_av = false
                av_list = l_person_hash['alternate values']
                av_list ||= {}
                av_list.each do |av|
                  if av.value == r_person.first_name
                    if av.type == 'AlternateValue::AlternateSpelling' &&
                        av.alternate_value_object_attribute == 'first_name' # &&
                      skip_av = true
                      break # stop looking in this bunch, if you found a match
                    end
                  end
                end

                AlternateValue::AlternateSpelling.create!(
                  alternate_value_object_type: 'Person',
                  value: r_person.first_name,
                  alternate_value_object_attribute: 'first_name',
                  alternate_value_object_id: id) unless skip_av
              end
            end
          end

          unless r_person.last_name.blank?
            if last_name.blank?
              self.update(last_name: r_person.last_name) # NameCase() ?
            else
              if self.last_name != r_person.last_name
                # create a last_name alternate_value of the r_person first name
                skip_av = false
                av_list = l_person_hash['alternate values']
                av_list ||= {}
                av_list.each do |av|
                  if av.value == r_person.last_name
                    if av.type == 'AlternateValue::AlternateSpelling' &&
                        av.alternate_value_object_attribute == 'last_name' # &&
                      skip_av = true
                      break # stop looking in this bunch, if you found a match
                    end
                  end
                end

                AlternateValue::AlternateSpelling.create!(
                  alternate_value_object_type: 'Person',
                  value:  r_person.last_name,
                  alternate_value_object_attribute: 'last_name',
                  alternate_value_object_id: id) unless skip_av
              end
            end
          end

          r_person.annotations_hash.each do |r_kee, r_objects|
            r_objects.each do |r_o|
              skip  = false
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
                r_o.annotated_object = self
                r_o.save!
              end
            end
          end

          # TODO: handle prefix and suffix
          if false && prefix.blank? ## DD: do not change the name of verified person
            write_attribute(:prefix, r_person.prefix)
          else
            unless r_person.prefix.blank?
              # What to do when both have some content?
            end
          end

          if false && suffix.blank? ## DD: do not change the name of verified person
            self.suffix = r_person.suffix
          else
            unless r_person.suffix.blank?
              # What to do when both have some content?
            end
          end

          # TODO: handle years attributes
          if year_born.nil?
            self.year_born = r_person.year_born
          else
            unless r_person.year_born.nil?
              # What to do when both have some (different) numbers?
            end
          end

          if year_died.nil?
            self.year_died = r_person.year_died
          else
            unless r_person.year_died.nil?
              # What to do when both have some (different) numbers?
            end
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
          # NO!!! -  unless self.persisted? (all people are at this point persisted!)
          self.save! if self.changed?
        end
      rescue ActiveRecord::RecordInvalid
        return false
      end
    end
    true
  end

  def hard_merge(person_id_to_destroy)
    return false if id == person_id_to_destroy
    begin
      person_to_destroy = Person.find(person_id_to_destroy)

      Person.transaction do
        merge_with(person_to_destroy.id)
        person_to_destroy.destroy!
      end

    rescue ActiveRecord::RecordNotDestroyed
      return false
    rescue ActiveRecord::RecordInvalid
      return false
    rescue ActiveRecord::RecordNotFound
      return false
    end
    true
  end

  # @return [Boolean]
  def is_determiner?
    determiner_roles.any?
  end

  # @return [Boolean]
  def is_taxon_name_author?
    taxon_name_author_roles.any?
  end

  # @return [Boolean]
  def is_georeferencer?
    georeferencer_roles.any?
  end

  # @return [Boolean]
  def is_author?
    author_roles.any?
  end

  # @return [Boolean]
  def is_editor?
    editor_roles.any?
  end

  # @return [Boolean]
  def is_source?
    source_roles.any?
  end

  # @return [Boolean]
  def is_collector?
    collector_roles.any?
  end

  # @param [String] name_string
  # @return [Array] of Hashes
  #   use citeproc to parse strings
  #   see also https://github.com/SpeciesFileGroup/taxonworks/issues/1161
  def self.parser(name_string)
    BibTeX::Entry.new(type: :book, author: name_string).parse_names.to_citeproc['author']
  end

  # @param [String] name_string
  # @return [Array] of People
  #    return people for name strings
  def self.parse_to_people(name_string)
    parser(name_string).collect { |n|
      Person::Unvetted.new(
        last_name: n['family'] ? NameCase(n['family']) : nil,
        first_name: n['given'] ? NameCase(n['given']) : nil,
        prefix: n['non-dropping-particle'] ? NameCase( n['non-dropping-particle']) : nil )}
  end

  # @param role_type [String] one of the Role types
  # @return [Scope]
  #    the max 10 most recently used (1 week, could parameterize) people
  def self.used_recently(user_id, role_type = 'SourceAuthor')
    t = Role.arel_table
    p = Person.arel_table

    # i is a select manager
    i = t.project(t['person_id'], t['type'], t['created_at']).from(t)
      .where(t['created_at'].gt(1.weeks.ago))
      .where(t['created_by_id'].eq(user_id))
      .where(t['type'].eq(role_type))
      .order(t['created_at'].desc)

    # z is a table alias
    z = i.as('recent_t')

    Person.joins(
      Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(z['person_id'].eq(p['id'])))
    ).pluck(:person_id).uniq
  end

  # @params Role [String] one the available roles
  # @return [Hash] geographic_areas optimized for user selection
  def self.select_optimized(user_id, project_id, role_type = 'SourceAuthor')
    r = used_recently(user_id, role_type)
    h = {
      quick: [],
      pinboard: Person.pinned_by(user_id).where(pinboard_items: {project_id: project_id}).to_a,
      recent: []
    }

    if r.empty?
      h[:quick] = Person.pinned_by(user_id).pinboard_inserted.where(pinboard_items: {project_id: project_id}).to_a
    else
      h[:recent] = Person.where('"people"."id" IN (?)', r.first(10) ).to_a
      h[:quick] = (
        Person.pinned_by(user_id).pinboard_inserted.where(pinboard_items: {project_id: project_id}).to_a +
        Person.where('"people"."id" IN (?)', r.first(4) ).to_a
      ).uniq
    end
    h
  end

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
    unless is_editor? || is_author?
      errors.add(:year_active_start, 'is older than year of death') if year_active_start && year_died && year_active_start > year_died
      errors.add(:year_active_end, 'is older than year of death') if year_active_end && year_died && year_active_end > year_died
    end
    true
  end

  # @return [Ignored]
  def not_active_before_birth
    errors.add(:year_active_start, 'is younger than than year of birth') if year_active_start && year_born && year_active_start < year_born
    errors.add(:year_active_end, 'is younger than year of birth') if year_active_end && year_born && year_active_end < year_born
  end

  # https://en.wikipedia.org/wiki/List_of_the_verified_oldest_people
  def not_gandalf
    errors.add(:base, 'fountain of eternal life does not exist yet') if year_born && year_died && year_died - year_born > 119
  end

  # https://en.wikipedia.org/wiki/List_of_the_verified_oldest_people
  def not_balrog
    errors.add(:base, 'nobody is that active') if year_active_start && year_active_end && (year_active_end - year_active_start > 119)
  end

  # TODO: deprecate this, always set explicitly
  # @return [Ignored]
  def set_type_if_blank
    self.type = 'Person::Unvetted' if self.type.blank?
  end

  # @return [Ignored]
  def set_cached
    update_column(:cached, bibtex_name)
    set_role_object_cached
  end

  # @return [Ignored]
  def set_role_object_cached
    if change_to_cached_attribute?
      roles.reload.each do |r|
        r.role_object.send(:set_cached) if r.role_object.respond_to?(:set_cached, true) # true -> check private methods
      end
    end
  end

  # @return [Boolean]
  # Difficult to anticipate what
  # attributes will be cached in different models
  def change_to_cached_attribute?
    saved_change_to_last_name? || saved_change_to_prefix? || saved_change_to_suffix?
  end

end

