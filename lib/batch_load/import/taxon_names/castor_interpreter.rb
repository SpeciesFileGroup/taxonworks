# TODO: THIS IS A GENERATED STUB, it does not function
module BatchLoad
  class Import::TaxonNames::CastorInterpreter < Import::TaxonifiToTaxonworks

    def initialize(nomenclature_code: nil, parent_taxon_name_id: nil, also_create_otu: false, **args)
      super
    end
    
    protected

    def build
      super
     
      if @processed
        namespace_castor = Namespace.find_by(name: 'Castor')

        @processed_rows.each do |processed_row_index, rp|
          # You need to subtract 2 from processed_row_index because processed_row_index is 1 based
          # so you need to subtract 1 from it to make it 0 based and csv object is missing the first RowParse
          # which were the headers so you need to subtract 1 again from it to account for the missing row
          csv_row_index = processed_row_index - 2
          taxon_name_identifer_taxon_concept = ""
          
          ap processed_row_index
          ap csv[csv_row_index]
        end
      end

      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      byebug
    end
  end
end
