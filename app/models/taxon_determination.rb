#  A Taxon determination is an assertion that a collection object belongs to a taxonomic *concept*.
#
#  If you wish to capture verbatim determinations then they should be added to CollectionObject#buffered_determinations, 
#  i.e. TaxonDeterminations are fully "normalized".
#
# @!attribute otu
#   @return [Otu] 
#   the OTU (concept) of the determination 
# @!attribute biological_collection_object 
#   @return [BiologicalCollectionObject] 
#   The object being determined.
# @!attribute determiner
#   @return [Person]
#   the Person making the determination
# @!attribute year_made
#   @return [String] 
#   the year the determination was made, abbreviations like '02' are allowed
# @!attribute month_made
#   @return [String] 
#   the month the determination was made. Literal values like Roman Numerals, abbreviations ('Jan.') etc. are allowed, but not all forms can be interpreted.
# @!attribute day_made
#   @return [String] 
#   the day of the month the determination was made 
class TaxonDetermination < ActiveRecord::Base
  acts_as_list scope: [:biological_collection_object_id]

  include Housekeeping
  include Shared::Citable
  include Shared::HasRoles
  include Shared::IsData

  belongs_to :otu, inverse_of: :taxon_determinations
  belongs_to :biological_collection_object, class_name: 'CollectionObject', inverse_of: :taxon_determinations

  has_one :determiner_role, class_name: 'Determiner', as: :role_object
  has_one :determiner, through: :determiner_role, source: :person

  accepts_nested_attributes_for :determiner, :determiner_role, allow_destroy: true

  # TODO: factor these out (see also TaxonDetermination, Source::Bibtex)
  validates_numericality_of :year_made,
                            only_integer:          true,
                            greater_than:          0,
                            less_than_or_equal_to: Time.now.year,
                            allow_nil:             true,
                            message:               ' must be a 4 digit integer greater than 0'
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

  validates :otu, presence: true
  validates :biological_collection_object, presence: true

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
