module Dwca::Import 

  def self.new_dwc(path_to_archive)
    DarwinCore.new(path_to_archive)   
  end

  class Manager 
    attr_accessor :field_index 
    attr_accessor :available_objects
    attr_accessor :row_number
    alias_method  :i, :row_number 
    attr_accessor :data, :errors
    attr_accessor :tw_objects

    def initialize(opts = {})
      opts = {
        data: [],        # dwc.core.read[0] 
        errors: [],      # dwc.core.read[1]
        core_fields: {}, # dwc.core.fields
        row_number: 1    # default starting row index
      }.merge!(opts)
      @data, @errors, @row_number = opts[:data], opts[:errors], opts[:row_number]
      @available_objects = referenced_models(opts[:core_fields]) 
      @tw_objects = TwObjects.new()
      @field_index = opts[:core_fields].inject({}){|hsh, a| hsh.merge(a[:term] => (a[:index]) )} 
    end

    def row_id(row)
      row[0] 
    end

    def cell(row, attribute)
      row[@field_index[attribute]]
    end

    def build_object(row, object)
      klass = object.class.name.underscore.to_sym
      DWC2TW[klass].keys.each do |attr|
        method = DWC2TW[klass][attr][:in]
        if object.respond_to?(method)
          object.send(method, cell(row, attr))
        end
      end
      object
    end

    # data that is not null
    def row_objects(row)
    end

    def build_row_objects(row, row_objects)
      result = row_objects.inject({}){|hsh, a| hsh.merge(a => nil)} # might need to be a hash
      row_objects.each do |r|
        result[r] = build_object(row, r.to_s.classify.constantize.new)
      end
      result 
    end

    # 2nd pass
    def relate_otu(row)
    end

    def self.build(data)
      data.rows[0..10].each do |row|
        puts ro
      end
    end

    protected

    # Given the core_fields what TW objects are possible
    def referenced_models(core_fields)
      core_fields = core_fields.collect{|i| i[:term]}
      models = []
      DWC2TW.keys.each do |k|
        if (core_fields & DWC2TW[k].keys) != []
          models.push k 
        end
      end
      models.sort
    end
  end

  def self.new_manager(darwin_core_archive)
    data, errors = darwin_core_archive.core.read
    Manger.new(
      data: data,
      errors: errors,
      core_fields: darwin_core_archive.core.fields 
    )
  end

  RUNTIME =  {
    'http://purl.org/dc/terms/modified'           => nil, # bubble up? 
    'http://purl.org/dc/terms/language'           => nil, # one of  http://www.ietf.org/rfc/rfc4646.txt
    'http://rs.tdwg.org/dwc/terms/collectionCode' => nil, # default='Insect Collection' the name, acronym, coden, or initialism identifying the collection or data set from which the record was derived.
    'http://rs.tdwg.org/dwc/terms/datasetID'      => nil, # An identifier for the set of data. May be a global unique identifier or an identifier specific to a collection or institution. 
    'http://rs.tdwg.org/dwc/terms/datasetName'    => nil, # default='Illinois Natural History Survey'  The name identifying the data set from which the record was derived.
    'http://rs.tdwg.org/dwc/terms/basisOfRecord'  => nil, # default='Preserved Specimen'               The specific nature of the data record - a subtype of the dcterms:type. Recommended best practice is to use a controlled vocabulary such as the Darwin Core Type Vocabulary (http://rs.tdwg.org/dwc/terms/type-vocabulary/index.htm). 
  }                                                          

  DWC2TW = {
    otu: {
      'http://rs.tdwg.org/dwc/terms/scientificName'           => {in: :name=, out: nil},
    },

    biological_association: {
      'http://rs.tdwg.org/dwc/terms/associatedTaxa' => {in: nil, out: nil}
    },

    taxon_name: {
      'http://rs.tdwg.org/dwc/terms/originalNameUsage' => {in: :name=, out: nil},
      'http://rs.tdwg.org/dwc/terms/taxonID'                  => {in: :dwc_parse_taxon_id, out: :id},
      'http://rs.tdwg.org/dwc/terms/originalNameUsage'        => {in: nil, out: nil},
      'http://rs.tdwg.org/dwc/terms/kingdom'                  => {in: nil, out: nil},
      'http://rs.tdwg.org/dwc/terms/phylum'                   => {in: nil, out: nil},
      'http://rs.tdwg.org/dwc/terms/class'                    => {in: nil, out: nil},
      'http://rs.tdwg.org/dwc/terms/order'                    => {in: nil, out: nil},
      'http://rs.tdwg.org/dwc/terms/family'                   => {in: nil, out: nil},
      'http://rs.tdwg.org/dwc/terms/genus'                    => {in: nil, out: nil},
      'http://rs.tdwg.org/dwc/terms/subgenus'                 => {in: nil, out: nil},
      'http://rs.tdwg.org/dwc/terms/specificEpithet'          => {in: nil, out: nil},
      'http://rs.tdwg.org/dwc/terms/infraspecificEpithet'     => {in: nil, out: nil},
      'http://rs.tdwg.org/dwc/terms/scientificNameAuthorship' => {in: nil, out: nil},
      'http://rs.tdwg.org/dwc/terms/scientificName'           => {in: nil, out: nil},
      'http://rs.tdwg.org/dwc/terms/nomenclaturalCode'        => {in: nil, out: :iczn_code?}
    },

    collection_object: { 
      'http://rs.tdwg.org/dwc/terms/institutionID'     => {in: nil, out: nil},               # Who owns it
      'http://rs.tdwg.org/dwc/terms/institutionCode'   => {in: nil, out: nil},             # The name (or acronym) in use by the institution having custody of the object(s) or information referred to in the record. 
      'http://rs.tdwg.org/dwc/terms/individualCount'   => {in: :total=, out: :total},
      'http://rs.tdwg.org/dwc/terms/sex'               => {in: :sex=, out: :sex},
    },

    collecting_event: {
      'http://rs.tdwg.org/dwc/terms/samplingProtocol'  => {in: :verbatim_method=, out: :verbatim_method},
      'http://rs.tdwg.org/dwc/terms/eventDate'         => {in: :dwc_parse_EventDate, out: :verbatim_method},   
      'http://rs.tdwg.org/dwc/terms/habitat'           => {in: :macro_habitat=, out: :habitat},
      'http://rs.tdwg.org/dwc/terms/locality'          => {in: :verbatim_locality, out: :verbatim_locality},
      'http://rs.tdwg.org/dwc/terms/verbatimElevation' => {in: :dwc_parse_verbatimElevation, out: :elevation},
      'http://rs.tdwg.org/dwc/terms/country'           => {in: nil, out: :country},
      'http://rs.tdwg.org/dwc/terms/stateProvince'     => {in: nil, out: :state},
      'http://rs.tdwg.org/dwc/terms/county'            => {in: nil, out: :county},
      'http://rs.tdwg.org/dwc/terms/waterBody'         => {in: nil, out: :water_body}                                    
    },

    georeference: {  
      'http://rs.tdwg.org/dwc/terms/coordinateUncertaintyInMeters' => {in: nil, out: nil},
      'http://rs.tdwg.org/dwc/terms/decimalLatitude'               => {in: :verbatim_latitude, out: :verbatim_latitude},
      'http://rs.tdwg.org/dwc/terms/decimalLongitude'              => {in: :verbatim_longitude, out: :verbatim_longitude},
    },

    biocuration_classification: {
      'http://rs.tdwg.org/dwc/terms/lifeStage' => {in: nil, out: nil}
    },

    identifier: {
      'http://rs.tdwg.org/dwc/terms/catalogNumber' => {in: nil, out: nil},
    },

    taxon_determination: {
      'http://rs.tdwg.org/dwc/terms/identifiedBy'   => {in: :dwc_parse_identifiedBy, out: :identified_by},
      'http://rs.tdwg.org/dwc/terms/dateIdentified' => {in: :dwc_parse_dateIdentified, out: :date_identified}
    },

    type_specimen: {
      'http://rs.tdwg.org/dwc/terms/typeStatus' => {in: :type_type, out: :type_type}
    },
  }


class TwObjects < Struct.new( *Dwca::Import::DWC2TW.keys.collect{|k| "#{k}s".to_sym }, :rows );
end


end


# methods parse dwcDate => returns month day year
# migrations collection_objects => home_repository, current_repository
