# A Citation is an assertion that the subject (i.e. citation object/record/data instance),
# or some attribute of it, was referenced or originated in a Source.
#
# @!attribute citation_object_type
#   @return [String]
#     Rails STI, the class of the object being cited
#
# @!attribute citation_object_id
#   @return [Integer]
#    Rails STI, the id of the object being cited
#
# @!attribute source_id
#   @return [Integer]
#   the source ID
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute pages
#   @return [String, nil]
#     a specific location/localization for the data in the Source, if you lead with an integer seperated by space or punctation that
#     integer will be returned as the "first" page and usable in direct linkouts to Documents if available
#
# @!attribute is_original
#   @return [Boolean]
#     is this the first citation in which the data were observed?
#
class Citation < ApplicationRecord

  # Citations do not have Confidence or DataAttribute.

  include Housekeeping
  include Shared::Notes
  include Shared::Tags
  include Shared::IsData
  include Shared::PolymorphicAnnotator
  include SoftValidation

  attr_accessor :no_cached

  polymorphic_annotates('citation_object')

  belongs_to :source, inverse_of: :citations

  has_many :citation_topics, inverse_of: :citation, dependent: :destroy
  has_many :topics, through: :citation_topics, inverse_of: :citations
  has_many :documents, through: :source

  # TODO: This is wrong, should be source
  validates_presence_of  :source_id

  validates_uniqueness_of :source_id, scope: [:citation_object_id, :citation_object_type, :pages]

  validates_uniqueness_of :is_original, scope: [:citation_object_type, :citation_object_id], message: 'origin can only be assigned once', allow_nil: true, if: :is_original?

  accepts_nested_attributes_for :citation_topics, allow_destroy: true, reject_if: :reject_citation_topics
  accepts_nested_attributes_for :topics, allow_destroy: true, reject_if: :reject_topic

  before_destroy :prevent_if_required

  after_create :add_source_to_project

  before_save {@old_is_original = is_original_was}
  before_save {@old_citation_object_id = citation_object_id_was}
  before_save {@old_source_id = source_id_was}

  after_save :update_related_cached_values, if: :is_original?

  after_save :set_cached_names_for_taxon_names, unless: -> {self.no_cached}
  after_destroy :set_cached_names_for_taxon_names, unless: -> {self.no_cached}

  soft_validate(:sv_page_range, set: :page_range)

  # TODO: deprecate
  # @return [Scope of matching sources]
  def self.find_for_autocomplete(params)
    term = params['term']
    ending = term + '%'
    wrapped = '%' + term + '%'
    joins(:source).where('sources.cached ILIKE ? OR sources.cached ILIKE ? OR citation_object_type LIKE ?', ending, wrapped, ending).with_project_id(params[:project_id])
  end

  # @return [Boolean]
  #   true if is_original is checked, false if nil/false
  def is_original?
    is_original ? true : false
  end

  # @return [String, nil]
  #    the first integer in the string, as a string
  def first_page
    /(?<i>\d+)/ =~ pages
    i
  end

  # @return [Integer, nil]
  #    if a target document
  def target_document_page
    target_document.try(:pdf_page_for, first_page).try(:first)
  end

  # @return [Document, nil]
  def target_document
    documents.order('documentation.position').first
  end

  protected

  def add_source_to_project
    !!ProjectSource.find_or_create_by(project: project, source: source)
  end

  def reject_citation_topics(attributed)
    attributes['id'].blank? && attributed['topic_id'].blank? && attributed['topic'].blank? && attributed['topic_attributes'].blank?
  end

  def reject_topic(attributed)
    attributed['name'].blank? || attributed['definition'].blank?
  end

  def update_related_cached_values
    if is_original != @old_is_original || citation_object_id != @old_citation_object_id || source_id != @old_source_id
      if citation_object_type == 'TaxonName'
        citation_object.update_columns(cached_author_year: citation_object.get_author_and_year,
                                       cached_nomenclature_date: citation_object.nomenclature_date)  if citation_object.persisted?
      end
    end
    true
  end

  # TODO: modify for asserted distributions and other origin style relationships
  def prevent_if_required
    if !marked_for_destruction? && !new_record? && citation_object.requires_citation? && citation_object.citations.reload.count == 1
      errors.add(:base, 'at least one citation is required')
      throw :abort
    end
  end

  def set_cached_names_for_taxon_names
    if is_original != @old_is_original || citation_object_id != @old_citation_object_id || source_id != @old_source_id
      if citation_object_type == 'TaxonNameRelationship' && TAXON_NAME_RELATIONSHIP_NAMES_INVALID.include?(citation_object.try(:type_name))
        begin
          TaxonNameRelationship.transaction do
            t = citation_object.subject_taxon_name
            vn = t.get_valid_taxon_name

            t.update_columns(
              cached: t.get_full_name,
              cached_html: t.get_full_name_html,
              cached_valid_taxon_name_id: vn.id)

            # @proceps: This and below is not updating cached names.  Is this required because timing (new dates) may change synonymy?
            t.combination_list_self.each do |c|
              c.update_column(:cached_valid_taxon_name_id, vn.id)
            end


            vn.list_of_invalid_taxon_names.each do |s|
              s.update_column(:cached_valid_taxon_name_id, vn.id)
              s.combination_list_self.each do |c|
                c.update_column(:cached_valid_taxon_name_id, vn.id)
              end
            end
          end
        rescue ActiveRecord::RecordInvalid
          raise
        end
        false
      end
    end
  end

  def sv_page_range
    if pages.blank?
      soft_validations.add(:pages, 'Citation pages are not provided')
    elsif !source.pages.blank?
      matchdata1 = pages.match(/(\d+) ?[-–] ?(\d+)|(\d+)/)
      if matchdata1
        citMinP = matchdata1[1] ? matchdata1[1].to_i : matchdata1[3].to_i
        citMaxP = matchdata1[2] ? matchdata1[2].to_i : matchdata1[3].to_i
        matchdata = source.pages.match(/(\d+) ?[-–] ?(\d+)|(\d+)/)
        if citMinP && citMaxP && matchdata
          minP = matchdata[1] ? matchdata[1].to_i : matchdata[3].to_i
          maxP = matchdata[2] ? matchdata[2].to_i : matchdata[3].to_i
          minP = 1 if minP == maxP && %w{book booklet manual mastersthesis phdthesis techreport}.include?(source.bibtex_type)
          unless (maxP && minP && minP <= citMinP && maxP >= citMaxP)
            soft_validations.add(:pages, 'Citation is out of the source page range')
          end
        end
      end
    end
  end

end
