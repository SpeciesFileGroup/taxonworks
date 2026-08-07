require 'rails_helper'

describe BatchLoad::Import::TaxonNames::NomenInterpreter, type: :model do

  let(:file_name) { 'spec/files/batch/taxon_name/NomenTest.tab' }
  let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }

  let(:root_taxon_name) { FactoryBot.create(:root_taxon_name) }

  let(:setup) {
    csv1 = CSV.read(
      file_name,
      headers: true,
      header_converters: :downcase,
      col_sep: "\t",
      encoding: 'UTF-8')
  }

  let(:import_params) {
    {
      parent_taxon_name_id: root_taxon_name.id,
      nomenclature_code: 'iczn',
      project_id:,
      user_id:,
      file: upload_file }
  }

  let(:import) { BatchLoad::Import::TaxonNames::NomenInterpreter.new( **import_params ) }

  #specify 'handle parent recursion errors gracefully' do
  #  f =  Rack::Test::UploadedFile.new('spec/files/batch/taxon_name/NomenTestRecursive.tab')
  #  p = import_params
  #  p[:file] = f
  #
  #  i =  BatchLoad::Import::TaxonNames::NomenInterpreter.new( **p )

  #  i.build
  #  expect(i.create).to be_truthy
  #end

  specify 'parent_taxon_name_id (provided)' do
    g = Protonym.create!(parent: root_taxon_name, name: 'Orderum', rank_class: Ranks.lookup(:iczn, :order))
    
    i = BatchLoad::Import::TaxonNames::NomenInterpreter.new( **import_params.merge(parent_taxon_name_id: g.id) )
    i.create
   
    expect(TaxonName.find_by(name: 'Aidae').parent_id).to eq(g.id)
    expect(TaxonName.find_by(name: 'Bidae').parent_id).to eq(g.id)
  end

  specify 'parent_taxon_name_id (provided)' do
    g = Protonym.create!(parent: root_taxon_name, name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus))
    i = BatchLoad::Import::TaxonNames::NomenInterpreter.new( **import_params.merge(parent_taxon_name_id: g.id) )
    expect(i.parent_taxon_name_id).to eq(g.id)
  end

  specify 'parent_taxon_name_id (root)' do
    expect(import.parent_taxon_name_id).to eq(root_taxon_name.id)
  end

  specify '.also_create_otu' do
    expect(import.also_create_otu).to be_falsey
  end

  specify '#year_of_publication 1' do
    expect(import.send(:year_of_publication, 'Smith, 1999')).to eq('1999')
  end

  specify '#year_of_publication 2' do
    expect(import.send(:year_of_publication, '(Smith, 1999)')).to eq('1999')
  end

  context 'with setup' do
    before { setup }

    specify '.new succeeds' do
      expect(import).to be_truthy
    end

    specify '#processed_rows' do
      expect(import.processed_rows.count).to eq(10) # now skips empties
    end

    specify '#processed_rows' do
      expect(import.create_attempted).to eq(false)
    end

    context 'after .create' do
      before { import.create }

      specify '#create_attempted' do
        expect(import.create_attempted).to eq(true)
      end

      specify '#valid_objects (after save)' do
        expect(import.valid_objects.count).to eq(16)
      end

      specify '#successful_rows' do
        expect(import.successful_rows).to be_truthy
      end

      specify '#total_records_created' do
        expect(import.total_records_created).to eq(16)
      end

      specify 'creates taxon names' do
        expect(TaxonName.all.count).to eq(11) # batch + 1 root
      end

      specify 'creates relationships' do
        expect(TaxonNameRelationship.all.count).to eq(4)
      end

      specify 'creates classifications' do
        expect(TaxonNameClassification.all.count).to eq(2) # not added to total, nested
      end

      specify 'creates otus' do
        expect(Otu.all.count).to eq(2)
      end

      specify 'creates identifiers' do
        expect(Identifier.all.count).to eq(3) # not added to total; 2 OTUs
      end

    end
  end

end
