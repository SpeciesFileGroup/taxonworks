require 'rails_helper'

describe 'TaxonWorks to DwC-A core mapping' do
  let(:core) { {} }
  
  context 'When name is governed by ICZN' do
        
    context 'When taxon is validly published' do
      # Build example models here and populate the hash. Please when doing so, also
      # show how would you retrieve the required model instances from the DB instead 
      # of just fulfilling the hash with the source models in isolation (e.g. building 
      # a citation and then just assigning its text representation to namePublishedIn
      # without showing how the name relates to the model is an incorrect example)
      
      xspecify 'taxonomicStatus' do
        # NOTE: Although SFS currently uses 'accepted' as is the preferred term in 
        # http://rs.gbif.org/vocabulary/gbif/taxonomic_status.xml, 'valid' could be used as well.
        # Decide which is best.
        expect(core[:taxonomicStatus]).to eq('accepted')
      end
      
      xspecify 'nomenclaturalStatus' do
        expect(core[:nomenclaturalStatus]).to eq('available')
      end
      
      xspecify 'scientificName' do
        expect(core[:scientificName]).to eq('Oedipoda caerulescens sardeti')
      end
      
      xspecify 'scientificNameAuthorship' do
        expect(core[:scientificNameAuthorship]).to eq('Defaut, 2006')
      end
      
      xspecify 'scientificNameID' do
        # NOTE: LSID must be supported, but not necessarily should be a requirement for all projects where this term
        # could be either be built from something else or not be used at all.
        expect(core[:scientificNameID]).to eq('urn:lsid:Orthoptera.speciesfile.org:TaxonName:67404')
      end
      
      xspecify 'taxonRank' do
        expect(core[:taxonRank]).to eq('subspecies')
      end
      
      xspecify 'namePublishedIn' do
        expect(core[:namePublishedIn]).to eq('Defaut. 2006. Révision préliminaire des Oedipoda ouest-paléarctiques (Caelifera, Acrididae, Oedipodinae). Matériaux Orthoptériques et Entomocénotiques 11:23-48')
      end
    end
  end

end
