require 'rails_helper'

# 
# use type: model to get a project/user
#
describe TaxonifiToTaxonworks, type: :model do

  let(:basic_headers) {  ["family", "genus", "species", "author", "year"] }
  let(:basic_csv) { 
    CSV.generate() do |csv|
      csv <<  basic_headers
      csv << ["Diapriidae", "Aus", "bus", "Smith", "1854"]
      csv << ["Scelionidae", "Bus", "cus", "Jones", "1854"]
      csv << ["Scelionidae", "Cus", nil, "Chapman", "1854"]
      csv << ["Scelionidae", "Bus", "dus", "Elroy", "1854"]
      csv << ["Playtgastridae", "Eus", "eus", nil, nil]
      csv
    end
  }

  let(:basic_csv_name_count) { 11 }

  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }
  let(:parent_taxon_name) { FactoryGirl.create(:root_taxon_name) }
  let(:iczn_family) { Protonym.create!(name: 'Aidae', rank_class: Ranks.lookup(:iczn, 'family'), parent: parent_taxon_name) }

  describe TaxonifiToTaxonworks::Import do
    let(:o) { TaxonifiToTaxonworks::Import.new }

    specify '#project' do
      expect(o).to respond_to(:project)
    end 

    context 'input' do
      specify '#user' do
        expect(o).to respond_to(:user)
      end 

      specify '#import_level' do
        expect(o).to respond_to(:import_level)
      end 

      specify '#parent_taxon_name' do
        expect(o).to respond_to(:parent_taxon_name)
      end 

      specify '#data' do
        expect(o).to respond_to(:data)
      end 

      specify '#data raises when passed non String' do
        expect {o.data = 1 }.to raise_error TaxonifiToTaxonworks::ParamError 
      end

      context 'default values for' do
        specify '#import_level defaults to :warn' do
          expect(o.import_level).to eq(:warn) 
        end 
     
        specify '#nomenclature_code defaults to that of parent when provided do'  do
          o.parent_taxon_name = iczn_family
          expect(o.nomenclature_code).to eq(:iczn)
        end 
      end
    end

    context 'processing/import' do
      specify '#csv' do
        expect(o).to respond_to(:csv)
      end 

      specify '#csv is built from data when data is set' do
        o.data = basic_csv
        expect(o.csv.class).to eq CSV::Table 
      end

      specify '#name_collection' do
        expect(o).to respond_to(:name_collection)
      end 

      context '#valid?' do
        specify '#valid?' do
          expect(o).to respond_to(:valid?)
        end
     
        specify '#valid? is true only with a project, user, nomenclatural_code, csv, import_level, and parent_taxon_name set ' do
          o.project = project
          o.user = user
          o.data = basic_csv 
          o.parent_taxon_name = parent_taxon_name
          o.nomenclature_code = :iczn
          expect(o.valid?).to eq(true)
        end
      end

      context 'building the name collection' do
        specify '#build_name_collection returns false with no csv' do
          expect(o.build_name_collection).to be_falsey 
        end 

        context 'with some basic data' do
          before { o.data = basic_csv}

          specify '#build_name_collection populates #name_collection with valid csv' do
            expect(o.build_name_collection).to be_truthy
          end

          context 'with collection built' do
            before {o.build_name_collection }

            specify 'names exist' do
              expect(o.name_collection.collection.count).to eq(basic_csv_name_count)
            end

            context 'building Protonyms' do

              before {
                o.project = project
                o.user = user
                o.parent_taxon_name = parent_taxon_name
                o.nomenclature_code = :iczn
              }

              specify 'is possible given basic_csv' do
                expect(o.build_protonyms).to be_truthy
              end

              context 'built Protonyms' do
                before{ o.build_protonyms }

                specify '#names_added' do
                  expect(o.names_added.count).to eq(basic_csv_name_count)
                end
              end
            end

          end
        end
      end

        


    end
  end


end
