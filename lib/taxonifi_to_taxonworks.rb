require 'taxonifi'

# 
# Batch loading of otherwise undocumented names
# Nomenclature code is taken from the parent name if provided
#
module TaxonifiToTaxonworks 

  class ParamError < StandardError; end;

  class Import
    attr_accessor :project, :user

    # How forgiving the import process is
    #  :warn -> all possible names will be added, with those not validating ignored
    #  :strict -> all or nothing
    attr_accessor :import_level

    # The input csv as String)
    attr_accessor :data

    # The resultant csv table
    attr_accessor :csv

    # The Taxonifi Name collection
    attr_accessor :name_collection

    # The parent for the top level names 
    attr_accessor :parent_taxon_name

    # The code (Rank Class) that new names will use
    attr_accessor :nomenclature_code

    # The successfully added names
    attr_accessor :names_added

    # The names that were not added in a :warn run
    attr_accessor :names_not_added

    def initialize(project: nil, user: nil, import_level: :warn, data: nil, parent_taxon_name: nil, nomenclature_code: nil)
      @project = project
      @user = user
      @parent_taxon_name = parent_taxon_name
      @import_level = import_level
      @data = data

      @nomenclature_code = nomenclature_code

      @names_added = []
      @names_not_added = []
    end

    def parent_taxon_name=(taxon_name)
      @parent_taxon_name = taxon_name
      @nomenclature_code = @parent_taxon_name.rank_class.nomenclatural_code 
    end

    def data=(value)
      raise TaxonifiToTaxonworks::ParamError, 'not legal input' if value.class != String 
      @data = value
      csv
      @data 
    end

    def csv
      @csv ||= CSV.parse(@data, {headers: true, header_converters: :downcase})
    end

    def valid?
       @data && @project && @user && @import_level && @parent_taxon_name  && @nomenclature_code ? true : false
    end

    def import
      begin 
        build_name_collection
        build_protonyms
      rescue
      end
    end

    def build_name_collection
      return false if @data.nil? || @csv.nil? 
      @name_collection ||= Taxonifi::Lumper.create_name_collection(csv: csv)
    end

    def build_protonyms
      return false unless valid?

      parents = {}

      csv
      build_name_collection 

      @name_collection.collection.each do |n|
        p = Protonym.new(
          name: n.name,
          verbatim_author: n.author,
          year_of_publication: n.year,
          rank_class: Ranks.lookup(@nomenclature_code, n.rank),
          by: @user
        )
        
        if n.parent.nil?
          p.parent = @parent_taxon_name
        else
          p.parent = parents[n.parent.id] 
        end

        if p.valid?
          p.save!
          @names_added.push(p)
          parents.merge!(n.id => p)
        else
          @names_not_added.push(p)
        end
      end

      true 
    end
  end


  def self.preview(file)
    [] 
  end

  # Intent is a form set of params
  def self.create(params)

    begin
      a = TaxonifiToTaxonworks::Import.new(params)
      a.build_name_collection 
      a.build_protonyms
    rescue
      raise
    end
    a.names_added
  end


end
