# An Otu (losely, operational taxonomic unit) can be thought of as a unit of study.  In most cases an otu is a taxon.
#
# An Otu is defined by its underlying data and may be labeled with a name (TaxonName). Otus are used to represent rows 
# in matrices, taxon pages, individuals or populations, or arbitrary clusters of organisms (e.g. 'unsorted specimens in this container').
# Otus are a primary unit of work in TaxonWorks.
#
# OTU is labeled with a name, either arbitrarily given or specificly linked to a taxon_name_id.
#
# TODO: Add simple semantics (same_as etc.) describing taxon_name_id
#
class Otu < ActiveRecord::Base
  include Housekeeping
  #include Shared::AlternateValues  # 1/26/15 with MJY - not going to allow alternate values in Burlap
  include Shared::Citable # TODO: have to think hard about this vs. using Nico's framework
  include Shared::DataAttributes
  include Shared::Identifiable
  include Shared::Notable
  include Shared::Taggable
  include Shared::IsData
  include SoftValidation

  has_paper_trail

  # Class constants

  belongs_to :taxon_name, inverse_of: :otus

  has_many :otu_contents, inverse_of: :otu, dependent: :destroy
  has_many :taxon_determinations, inverse_of: :otu, dependent: :destroy
  has_many :collection_objects, through: :taxon_determinations, source: :biological_collection_object, inverse_of: :otus
  has_many :collection_profiles # @proceps dependent: what?
  has_many :topics, through: :otu_contents, source: :topic
  

  scope :with_taxon_name_id, -> (taxon_name_id) { where(taxon_name_id: taxon_name_id) }
  scope :with_name, -> (name) { where(name: name) }
  scope :not_self, -> (id) { where('otus.id <> ?', id) }

  #  validates_uniqueness_of :name, scope: :taxon_name_id

  before_validation :check_required_fields

  soft_validate(:sv_taxon_name, set: :taxon_name)
  soft_validate(:sv_duplicate_otu, set: :duplicate_otu)

  def otu_name
    if !self.name.blank?
      self.name
    elsif !self.taxon_name_id.nil?
      self.taxon_name.cached_name_and_author_year
    else
      nil
    end
  end

  #region Validation

  def check_required_fields
    if self.taxon_name_id.nil? && self.name.blank?
      errors.add(:taxon_name_id, 'Name and/or Taxon should be selected')
      errors.add(:name, 'Name and/or Taxon should be selected')
    end
  end

  #end region

  # Hernán - this is extremely hacky, I'd like to
  # map core keys to procs, use yield:, use cached values,
  # add logic for has_many handling (e.g. identifiers) etc.
  # ultmately, each key maps to a proc that returns a value
  #
  def dwca_core
    core = Dwca::GbifProfile::CoreTaxon.new
    
    core.nomenclaturalCode = (taxon_name.rank_class.nomenclatural_code.to_s.upcase)
    core.taxonomicStatus = (taxon_name.unavailable_or_invalid? ? nil : 'accepted')
    core.nomenclaturalStatus = (taxon_name.unavailable? ? nil : 'available')
    core.scientificName =  taxon_name.get_full_name_no_html                           
    core.scientificNameAuthorship = taxon_name.get_author_and_year       
    core.scientificNameID = taxon_name.identifiers.first.identifier      
    core.taxonRank = taxon_name.rank  
    core.namePublishedIn = taxon_name.source.cached  
    core
  end

  #region Soft validation
  def sv_taxon_name
    soft_validations.add(:taxon_name_id, 'Taxon is not selected') if self.taxon_name_id.nil?
  end

  def sv_duplicate_otu
    unless Otu.with_taxon_name_id(self.taxon_name_id).with_name(self.name).not_self(self.id).with_project_id(self.project_id).empty?
      soft_validations.add(:taxon_name_id, 'Duplicate Taxon and Name combination')
      soft_validations.add(:name, 'Duplicate Taxon and Name combination')
    end
  end

  #endregion

  def self.find_for_autocomplete(params)
    Queries::OtuAutocompleteQuery.new(params[:term]).all
  end

  # Generate a CSV version of the raw Otus table for the given project_id
  # Ripped from http://railscasts.com/episodes/362-exporting-csv-and-excel
  # Older version commented out
  # def self.generate_download(project_id: nil)
  #   CSV.generate do |csv|
  #     csv << column_names
  #     all.with_project_id(project_id).order(id: :asc).each do |otu|
  #       csv << otu.attributes.values_at(*column_names)
  #     end
  #   end
  # end
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


  def self.batch_preview(file: nil, ** args)
    f     = CSV.read(file, headers: true, col_sep: "\t", skip_blanks: true, header_converters: :symbol)
    @otus = []
    f.each do |row|
      @otus.push(Otu.new(name: row[:name]))
    end
    @otus
  end

  def self.batch_create(otus: {}, ** args)
    new_otus = []
    begin
      Otu.transaction do
        otus.keys.each do |k|
          o = Otu.new(otus[k])
          o.save!
          new_otus.push(o)
        end
      end
    rescue
      return false
    end
    new_otus
  end




end



