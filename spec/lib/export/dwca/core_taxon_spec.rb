# SEE https://github.com/SpeciesFileGroup/taxonworks/issues/1783

require 'rails_helper'
require 'export/dwca/gbif_profile/core_taxon'

describe "TaxonWorks to GBIF's DwC-A profile core file mapping" do
  let (:citation) { 'Defaut (2006) Révision préliminaire des Oedipoda ouest-paléarctiques (Caelifera, Acrididae, Oedipodinae). <i>Matériaux Orthoptériques et Entomocénotiques</i>, 11, 23–48.' }

  let(:core) {
    ProjectsAndUsers.spin_up_projects_users_and_housekeeping

    # TODO REMOVE!! 
    Current.user_id = 1

    source = Source::Bibtex.new(
      bibtex_type: 'article',
      year: '2006',
      author: 'Defaut',
      title: 'Révision préliminaire des Oedipoda ouest-paléarctiques (Caelifera, Acrididae, Oedipodinae)',
      volume: '11',
      pages: '23-48',
      journal: 'Matériaux Orthoptériques et Entomocénotiques'
    )

    source.save!

    r = find_or_create_root_taxon_name 
    g = Protonym.create(name: 'Oedipoda', rank_class: Ranks.lookup(:iczn, 'genus'), parent: r)
    s = Protonym.create(name: 'caerulescens', rank_class: Ranks.lookup(:iczn, 'species'), parent: g)
    ss = Protonym.create(name: 'sardeti', rank_class: Ranks.lookup(:iczn, 'subspecies'), parent: s, source: source)

    ss.identifiers << Identifier::Global::Lsid.new(identifier: 'urn:lsid:Orthoptera.speciesfile.org:TaxonName:67404')

    otu = Otu.create(taxon_name: ss)

    otu.dwca_core 
  }

  after(:all) {
    ProjectsAndUsers.clean_slate
  }

  xcontext 'When name is governed by ICZN' do

    specify 'nomenclaturalCode' do
      expect(core.nomenclaturalCode).to eq('ICZN')
    end

    context 'When taxon is validly published' do
      # Build example models here and populate the hash. Please when doing so, also
      # show how would you retrieve the required model instances from the DB instead 
      # of just fulfilling the hash with the source models in isolation (e.g. building 
      # a citation and then just assigning its text representation to namePublishedIn
      # without showing how the name relates to the model is an incorrect example)

      specify 'taxonomicStatus' do
        # NOTE: Although SFS currently uses 'accepted' as is the preferred term in 
        # http://rs.gbif.org/vocabulary/gbif/taxonomic_status.xml, 'valid' could be used as well.
        # Decide which is best.
        expect(core.taxonomicStatus).to eq('accepted')
      end

      # http://rs.gbif.org/vocabulary/gbif/nomenclatural_status.xml  
      # We need to map Nomen to this, task for @proceps
      specify 'nomenclaturalStatus' do
        expect(core.nomenclaturalStatus).to eq('available')
      end

      specify 'scientificName' do
        expect(core.scientificName).to eq('Oedipoda caerulescens sardeti')
      end

      specify 'scientificNameAuthorship' do
        expect(core.scientificNameAuthorship).to eq('Defaut, 2006')
      end

      specify 'scientificNameID' do
        # NOTE: LSID must be supported, but not necessarily should be a requirement for all projects where this term
        # could be either be built from something else or not be used at all.
        expect(core.scientificNameID).to eq('urn:lsid:Orthoptera.speciesfile.org:TaxonName:67404')
      end

      specify 'taxonRank' do
        expect(core.taxonRank).to eq('subspecies')
      end

      specify 'namePublishedIn' do
        expect(core.namePublishedIn).to eq(citation)
      end
    end
  end

end
