require 'rails_helper'

describe BatchLoad::Import::Otus::DataAttributesInterpreter, type: :model do

  let(:file_ph_1) { 'spec/files/batch/otu/da_ph_1.tsv' }
  let(:file_ph_2) { 'spec/files/batch/otu/da_ph_2.tsv' }
  let(:file_name) { 'spec/files/batch/otu/OtuTest.tsv' }
  let(:names) do
    bingo = import
    bingo.create
  end
  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }

  let(:upload_file) { fixture_file_upload(file_name) }
  let(:import) { BatchLoad::Import::Otus.new(project_id: project.id,
                                             user_id: user.id,
                                             file: upload_file)
  }

  let(:source) { FactoryBot.create(:valid_source_verbatim) }
  let(:upload_file_2) { fixture_file_upload(file_ph_2) }
  let(:import_2) { BatchLoad::Import::Otus::DataAttributesInterpreter.new(project_id: project.id,
                                                                          user_id: user.id,
                                                                          file: upload_file_2,
                                                                          source_id: source.id,
                                                                          create_new_otu: '1')
  }
  let(:import_3) { BatchLoad::Import::Otus::DataAttributesInterpreter.new(project_id: project.id,
                                                                          user_id: user.id,
                                                                          file: upload_file_2,
                                                                          create_new_otu: '1')
  }
  let(:import_4) { BatchLoad::Import::Otus::DataAttributesInterpreter.new(project_id: project.id,
                                                                          user_id: user.id,
                                                                          file: upload_file_2)
  }
  let(:import_5) { BatchLoad::Import::Otus::DataAttributesInterpreter.new(project_id: project.id,
                                                                          user_id: user.id,
                                                                          file: upload_file_2,
                                                                          source_id: source.id)
  }
  let(:import_6) { BatchLoad::Import::Otus::DataAttributesInterpreter.new(project_id: project.id,
                                                                          user_id: user.id,
                                                                          file: upload_file_2,
                                                                          create_new_otu: '1')
  }

  # rubocop:disable Rails/SaveBang
  context 'scanning tsv lines to evaluate data' do
    context 'file provided' do
      it 'loads data for review' do
        names
        bingo = import_2
        expect(bingo).to be_truthy
      end

      context 'finds some errors' do
        specify 'of \'predicate\' type' do
          bingo = import_2
          expect(bingo.processed_rows[6].parse_errors.flatten).to include("No contents for 'Predicate' was provided.")
        end

        specify 'of \'value\' type' do
          bingo = import_2
          expect(bingo.processed_rows[5].parse_errors.flatten).to include("No contents for 'Value' was provided.")
        end

        specify 'of \'multiple otu\' type' do
          names
          Otu.create(name: 'Aus bus')
          bingo = import_2
          expect(bingo.processed_rows[1].parse_errors.flatten).to include("Can't resolve multiple found otus.")
        end

        specify 'of combination exists type' do
          names
          # this one matches one in the import_2 file
          an_otu = Otu.create(name: 'Aus bus')
          a_da = ImportAttribute.new(import_predicate: 'TotalSpecies',
                                     value: 22)
          an_otu.data_attributes << a_da
          bingo = import_2
          expect(bingo.processed_rows[1].parse_errors.flatten)
              .to include('otu/predicate/value combination already exists.')
        end
      end

      context 'process non-error combinations' do
        let(:attribute_matches) {
          # this one matches one in the import_2 file
          an_otu = Otu.create(name: 'Aus bus')
          a_da = ImportAttribute.new(import_predicate: 'TotalSpecies',
                                     value: 22)
          an_otu.data_attributes << a_da
          # this one is included to provide another matching data_attribute not associated with Aus bus
          an_otu = Otu.create(name: 'Nuther bus')
          a_da = ImportAttribute.new(import_predicate: 'TotalSpecies',
                                     value: 22)
          an_otu.data_attributes << a_da

        }
        let(:start) { {otus: Otu.count, das: ImportAttribute.count} }
        context 'multiple otus and multiple data_attributes' do
          specify 'check otus' do
            names # provides one otu Aus bus, without data_attribute
            attribute_matches # provides multiple matching attributes and ots
            start # check object count
            bingo = import_2
            bingo.create
            expect(Otu.count).to eq(start[:otus] + 4)
          end

          specify 'check data_attributes' do
            names # provides one otu Aus bus, without data_attribute
            attribute_matches # provides multiple matching attributes and ots
            start # check object count
            bingo = import_2
            bingo.create
            expect(ImportAttribute.count).to eq(start[:das] + 4)
          end
        end
      end
    end
  end

  context 'building objects from valid tsv lines' do
    context 'two new otus' do
      context 'otu count' do
        it 'loads reviewed data' do
          names
          bingo = import_2
          bingo.create
          # names creates 7 otus, and import_2 finds one (not added), four new ones (two were not saved because of
          # errors in predicate or value)
          expect(Otu.count).to eq(11)
        end
      end

      context 'data_attribute count' do
        it 'loads reviewed data' do
          names
          bingo = import_2
          bingo.create
          expect(DataAttribute.count).to eq(5)
        end

        specify 'no otu creation attempted for error lines' do
          bingo = import_2
          bingo.create
          expect(Otu.count).to eq(5)
        end
      end
    end

    context 'match to taxon name, not otu' do
      context 'data_attribute check' do
        let(:d_a) { DataAttribute.new(type: 'ImportAttribute',
                                      import_predicate: 'connection to otu',
                                      value: 'new data attribute for the otu',
                                      project_id: project.id) }
        let(:otu) { Otu.find_by_name('americana') }
        let(:t_n) { FactoryBot.create(:valid_taxon_name, {name: 'Taxonmatchidae'}) }

        it 'finds otu through taxon name' do
          names
          otu.data_attributes << d_a
          otu.taxon_name = t_n
          start = DataAttribute.count
          otu.save
          bingo = import_2
          bingo.create
          # one data attribute is created here,
          # import_2 creates four data attributes directly by otu name,
          # and one by reference to a taxon_name
          expect(DataAttribute.count).to eq(start + 5)
        end
      end

      context 'otu check' do
        let(:d_a) { DataAttribute.new(type: 'ImportAttribute',
                                      import_predicate: 'connection to otu',
                                      value: 'new data attribute for the otu',
                                      project_id: project.id) }
        let(:otu) { Otu.find_by_name('americana') }
        let(:t_n) { FactoryBot.create(:valid_taxon_name, {name: 'Taxonmatchidae'}) }

        it 'finds otu through taxon name' do
          names
          otu.data_attributes << d_a
          otu.taxon_name = t_n
          otu.save
          start = Otu.count
          bingo = import_2
          bingo.create
          # one data attribute is created here,
          # import_2 creates four data attributes directly by otu name,
          # and one by reference to a taxon_name
          expect(Otu.count).to eq(start + 3)
        end
      end
    end

    context 'differnt params' do
      context 'create unmatched otus' do
        specify 'is true' do
          names
          start = Otu.count
          bingo = import_6
          bingo.create
          expect(Otu.count).to eq(start + 4)
        end

        specify 'is false' do
          names
          start = Otu.count
          bingo = import_5
          bingo.create
          expect(Otu.count).to eq(start)
        end
      end

      context 'source id' do
        specify 'is specified' do
          bingo = import_2
          bingo.create
          expect(Citation.count).to eq(5)
        end

        specify 'is not specified' do
          bingo = import_4
          bingo.create
          expect(Citation.count).to eq(0)
        end
      end
    end
  end
end
# rubocop:enable Rails/SaveBang
