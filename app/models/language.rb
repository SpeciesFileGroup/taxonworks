# This is a 1:1 representation of ISO 639-2.
# It is built on initialization with a rake task, and not further touched.
# Many of the languages have multiple version (e.g. there are 4 variations of German)
#
# @!attribute alpha_3_bibiographic
#   @return [String] attribute alpha_3_bibliographic always has a distinct 3 character value
#
# @!attribute alpha_3_terminologic
#   @return [String]
#
# @!attribute alpha_2
#   @return [String] alpha_2 will have either a 2 character value or and empty string ('')
#
# @!attribute english_name
#   @return [String] english_name may be more than one word long
#     (e.g. 'English, Middle (1100-1500)', 'Filipino; Pilipino','Finno-Ugrian languages')
#
# @!attribute french_name
#   @return [String] french_name may be more than one word long
#
class Language < ApplicationRecord
  include Housekeeping::Users
  include Housekeeping::Timestamps
  include Shared::IsData
  include Shared::IsApplicationData

  has_many :serials, inverse_of: :language, foreign_key: :primary_language_id
  has_many :sources, inverse_of: :source_language, class_name: 'Source::Bibtex'
  has_many :alternate_value_translations, class_name: 'AlternateValue::Translation'

  scope :used_recently_on_sources, -> { joins(sources: [:project_sources]).includes(sources: [:project_sources]).where(sources: { updated_at: 10.weeks.ago..Time.now } ).order('"sources"."created_at" DESC') }
  
 
  # TODO: dry 
  scope :used_recently_on_serials, -> { joins(:serials).includes(:serials).where(serials: { updated_at: 10.weeks.ago..Time.now } ).order('"serials"."created_at" DESC') }
  scope :used_recently_on_alternate_values, -> { joins(:alternate_value_translations).includes(:alternate_value_translations).where(alternate_values: { updated_at: 10.weeks.ago..Time.now } ).order('"alternate_values"."created_at" DESC') }

  scope :with_english_name_containing, ->(name) {where('english_name ILIKE ?', "%#{name}%")}  # non-case sensitive comparison

  validates_presence_of :english_name, :alpha_3_bibliographic

  def self.with_english_name_or_abbreviation(value)
    value = [value] if value.class == String

    t = Language.arel_table
    a = t[:english_name].matches_any(value)
    b = t[:alpha_2].matches_any(value)
    c = t[:alpha_3_bibliographic].matches_any(value)
    d = t[:alpha_3_terminologic].matches_any(value)
    Language.where(a.or(b).or(c).or(d).to_sql)
  end

  def self.find_for_autocomplete(params)
    term = "#{params[:term]}%"
    where('english_name ILIKE ? OR english_name = ?', term, params[:term])
  end

  # @param klass ['Source' || 'Serial']
  def self.select_optimized(user_id, project_id, klass = 'Source')
    recent = if klass == 'Source'
               Language.used_recently_on_sources.where('project_sources.project_id = ? AND sources.updated_by_id = ?', project_id, user_id).distinct.limit(10)
             elsif klass == 'Serial'
               Language.used_recently_on_serials.where('serials.updated_by_id = ?', user_id).distinct.limit(10).to_a
             end
    h = {
      recent: recent,
      pinboard: Language.pinned_by(user_id).pinned_in_project(project_id).to_a
    }

    quick = if klass == 'Source'
              Language.used_recently_on_sources.where('project_sources.project_id = ? AND sources.updated_by_id = ?', project_id, user_id).distinct.limit(4)
            elsif klass == 'Serial'
              Language.used_recently_on_serials.where('serials.updated_by_id = ?', user_id).distinct.limit(4).to_a
            elsif klass == 'AlternateValue'
              Language.used_recently_on_alternate_values.where('alternate_values.updated_by_id = ?', user_id).distinct.limit(4).to_a
            end

    h[:quick] = (Language.pinned_by(user_id).pinboard_inserted.pinned_in_project(project_id).to_a  + quick).uniq
    h
  end

end
