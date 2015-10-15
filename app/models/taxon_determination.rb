# A Taxon determination is an assertion that a collection object belongs to a taxonomic *concept*.
#
# If you wish to capture verbatim determinations then they should be added to CollectionObject#buffered_determinations,
# i.e. TaxonDeterminations are fully "normalized".
#
# Note: Following line not displayed in Yard (copied here so you can find it in context in the code):
# @todo factor these out (see also TaxonDetermination, Source::Bibtex)
#
# @!attribute biological_collection_object_id
#   @return [Integer]
#   BiologicalCollectionObject, the object being determined
#
# @!attribute otu_id
#   @return [Integer]
#   the OTU (concept) of the determination
#
# @!attribute position
#   @return [Integer]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute year_made
#   @return [Integer]
#   the year the determination was made, abbreviations like '02' are allowed
#   @todo this column used to be a String; would '02' be a legitimate Integer value?
#
# @!attribute month_made
#   @return [Integer]
#   the month the determination was made. Literal values like Roman Numerals, abbreviations ('Jan.') etc. are allowed, but not all forms can be interpreted.
#   @todo this column used to be a String; I don't think Roman numerals or abbreviations could be entered any longer
#
# @!attribute day_made
#   @return [Integer]
#   the day of the month the determination was made
#
class TaxonDetermination < ActiveRecord::Base
  acts_as_list scope: [:biological_collection_object_id]

  include Housekeeping
  include Shared::Citable
  include Shared::HasRoles
  include Shared::IsData

  belongs_to :otu, inverse_of: :taxon_determinations
  belongs_to :biological_collection_object, class_name: 'CollectionObject' #, inverse_of: :taxon_determinations

  has_many :determiner_roles, class_name: 'Determiner', as: :role_object
  has_many :determiners, through: :determiner_roles, source: :person

  validates :biological_collection_object, presence: true
  validates :otu, presence: true

  accepts_nested_attributes_for :determiners, :otu, :biological_collection_object, :determiner_roles, allow_destroy: true

  # @todo factor these out (see also TaxonDetermination, Source::Bibtex)
  validates_numericality_of :year_made,
                            only_integer:          true,
                            greater_than:          1757,
                            less_than_or_equal_to: Time.now.year,
                            allow_nil:             true,
                            message:               ' must be a 4 digit integer greater than 1757'
  validates_inclusion_of :month_made,
                         in:        1..12,
                         allow_nil: true,
                         message:   ' is not an integer from 1-12'
  validates_numericality_of :day_made,
                            unless:                'year_made.nil? || month_made.nil? || ![*(1..12)].include?(month_made)',
                            allow_nil:             true,
                            only_integer:          true,
                            greater_than:          0,
                            less_than:             32,
                            less_than_or_equal_to: Proc.new { |a| Time.utc(a.year_made, a.month_made).end_of_month.day },
                            message:               '%{value} is not valid for the month provided'

  before_save :set_made_fields_if_not_provided

  def date
    [year_made, month_made, day_made].compact.join("-")
  end

  def sort_date
    Utilities::Dates.nomenclature_date(day_made, month_made, year_made)
  end

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

  protected

  def set_made_fields_if_not_provided
    if self.year_made.blank? && self.month_made.blank? && self.day_made.blank?
      self.year_made  = Time.now.year
      self.month_made = Time.now.month
      self.day_made   = Time.now.day
    end
  end

end
