# Verbatim - Subclass of Source that represents a pasted copy of a reference.
# This class is provided to support rapid data entry for later normalization.
# Once the Source::Verbatim information has been broken down into a a valid Source::Bibtex or Source:Human,
# the verbatim source is no longer available.
#
# @!attribute verbatim
#   @return [String]
#   This is the only valid attribute of Source::Verbatim. It is the verbatim representation of the source.
#
class Source::Verbatim < Source

  include Shared::OriginRelationship

  IGNORE_IDENTICAL = [:serial_id, :address, :annote, :booktitle, :chapter, :crossref,
                      :edition, :editor, :howpublished, :institution, :journal, :key,
                      :month, :note, :number, :organization, :pages, :publisher, :school,
                      :series, :title, :volume, :doi, :abstract, :copyright, :language,
                      :stated_year, :bibtex_type, :day, :year, :isbn, :issn,
                      :verbatim_contents, :verbatim_keywords, :language_id, :translator,
                      :year_suffix, :url, :author, :cached, :cached_author_string,
                      :cached_nomenclature_date].freeze
  IGNORE_SIMILAR = IGNORE_IDENTICAL.dup.freeze

  is_origin_for 'Source::Bibtex', 'Source::Verbatim'
  originates_from 'Source::Bibtex', 'Source::Verbatim'

  attr_accessor :convert_to_bibtex

  before_validation :to_bibtex, if: -> { convert_to_bibtex }
  before_validation :switch_type, if: -> { persisted? && (type != 'Source::Verbatim') }

  after_save :reset_cached, if: -> { type != 'Source::Verbatim' }

  validates_presence_of :verbatim, if: -> { type == 'Source::Verbatim' }
  validate :only_verbatim_is_populated, if: -> { type == 'Source::Verbatim' }

  # @return [Nil]
  def authority_name
    nil
  end

  # @return [Nil]
  def date
    nil
  end

  # @return [Source, Boolean]
  def generate_bibtex
    return false if verbatim.blank?
    result = TaxonWorks::Vendor::Serrano.new_from_citation(citation: verbatim)
    if result.type == 'Source::Bibtex'
      result
    else
      false
    end
  end

  # @param [Source] source
  # @return [Boolean]
  # def similar(source)
  #   false
  # end

  # @param [Source] source
  # @return [Boolean]
  # def identical(source)
  #   false
  # end


  # @retun [nil]
  #   verbatim sources do not have nomenclature dates, but this method is used in catalogs
  def nomenclature_date
    nil
  end

  protected

  def reset_cached
    Source.find(id).send(:set_cached)
  end

  def to_bibtex(user_id = nil)
    user_id = updated_by_id if user_id.nil?
    if a = generate_bibtex
      if a.valid?
        b = a.attributes
        %w{id created_at updated_at created_by_id updated_by_id}.each do |c|
          b.delete(c)
        end
        b.merge(updated_at: Time.now, updated_by_id: user_id)
        update_columns(b)
        metamorphosize
      end
    else
      false
    end
  end

  def switch_type
    if Source.new(attributes).valid?
      update_column(:type, type)
      metamorphosize
    else
      errors.add(:base, 'conversion has invalid attributes')
    end
  end

  # @return [Ignored]
  def set_cached
    update_column(:cached, verbatim)
  end

  # @return [Ignored]
  def only_verbatim_is_populated
    self.attributes.each do |k, v|
      next if %w{id type cached verbatim created_by_id updated_by_id created_at updated_at}.include?(k)
      errors.add(k, 'can not be provided to a verbatim reference') if !v.blank?
    end
  end

end
