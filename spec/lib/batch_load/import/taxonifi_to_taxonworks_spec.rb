require 'rails_helper'

describe BatchLoad::Import::TaxonifiToTaxonworks, type: :model do

  # We assume all projects are starting with root
  let(:root_taxon_name) { FactoryBot.create(:root_taxon_name) }

  let(:basic_headers) {  ['family', 'genus', 'species', 'author', 'year'] }

  let(:basic_csv) { 
    CSV.generate() do |csv|
      csv <<  basic_headers
      csv << ['Diapriidae', 'Aus', 'bus', 'Smith', '1854']
      csv << ['Scelionidae', 'Bus', 'cus', 'Jones', '1854']
      csv << ['Scelionidae', 'Cus', nil, 'Chapman', '1854']
      csv << ['Scelionidae', 'Bus', 'dus', 'Elroy', '1854']
      csv << ['Playtgastridae', 'Eus', 'eus', nil, nil]
      csv
    end
  }

  let(:basic_csv_name_count) { 11 }

  let(:iczn_family) { Protonym.create!(name: 'Aidae', rank_class: Ranks.lookup(:iczn, 'family'), parent: root_taxon_name) }

  # TODO: rebuild these

  context 'plants' do

    let(:plantae) { TaxonName.create(rank_class: Ranks.lookup(:icn, :kingdom), name: 'Plantae', parent: root_taxon_name) }

    let(:plant_headers) { %w{phylum class order family genus species subspecies} }

    let(:plant_csv) { 
      CSV.generate(col_sep: "\t") do |csv|
        csv <<  plant_headers 
        csv << ['Tracheophyta', 'Magnoliopsida', 'Lamiales', 'Orobanchaceae', 'Agalinis','tenuifolia', ]
        csv << ['Tracheophyta', 'Magnoliopsida', 'Lamiales', 'Lamiaceae', 'Lycopus', 'americanus', ]
        csv << ['Tracheophyta', 'Magnoliopsida', 'Lamiales', 'Lamiaceae', 'Lycopus', 'americanus' 'sp. interior' ] # An invalid name, but shouldn't prevent others from loading
        csv 
      end
    }

    let(:temp_plants) do
      t = Tempfile.new(['foo', '.csv'])
      t.write(plant_csv.to_s)
      t.rewind
      t
    end

    let(:plant_params) { 
      {
        file: temp_plants, 
        parent_taxon_name_id: nil,
        nomenclature_code: :icn,
        also_create_otu: false,
        user_id: user_id,
        project_id: project_id,
        import_level: :warn
      }
    }

    specify '#create' do
      r = BatchLoad::Import::TaxonifiToTaxonworks.new(**plant_params)
      assert r.create
    end

    specify '#ready_to_create? without parent' do
      r = BatchLoad::Import::TaxonifiToTaxonworks.new(**plant_params)
      expect(r.ready_to_create?).to be_falsey
    end

    specify '#ready_to_create? with parent' do
      plant_params[:parent_taxon_name_id] = plantae.id
      r = BatchLoad::Import::TaxonifiToTaxonworks.new(**plant_params)
      expect(r.ready_to_create?).to be_truthy
    end

    specify '#parent_taxon_name without assignment adds error' do
      r = BatchLoad::Import::TaxonifiToTaxonworks.new(**plant_params)
      r.create
      expect(r.errors).to include('Provided parent taxon name id not valid.')
    end

    specify 'with #parent_taxon_name_id assigns parent to names' do
      plant_params[:parent_taxon_name_id] = plantae.id
      r = BatchLoad::Import::TaxonifiToTaxonworks.new(**plant_params)
      r.create
      expect(TaxonName.where(parent_id: nil).count).to eq(1) # Just Root
    end

    specify 'assigns :creator and :updator to TaxonName' do
      plant_params[:parent_taxon_name_id] = plantae.id
      r = BatchLoad::Import::TaxonifiToTaxonworks.new(**plant_params)
      r.create
      expect(TaxonName.where(created_by_id: nil).count).to eq(0) 
      expect(TaxonName.where(updated_by_id: nil).count).to eq(0) 
    end

  end

end
