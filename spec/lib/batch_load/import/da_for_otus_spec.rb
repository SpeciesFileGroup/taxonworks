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

  let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }
  let(:import) { BatchLoad::Import::Otus.new(project_id: project.id,
                                             user_id: user.id,
                                             file: upload_file)
  }

  let(:source) { FactoryBot.create(:valid_source_verbatim) }
  let(:upload_file_2) { Rack::Test::UploadedFile.new(file_ph_2) }
  let(:import_2_im) { BatchLoad::Import::Otus::DataAttributesInterpreter.new(project_id: project.id,
                                                                             user_id: user.id,
                                                                             file: upload_file_2,
                                                                             type_select: 'import',
                                                                             source_id: source.id,
                                                                             create_new_predicate: 'on',
                                                                             create_new_otu: '1')
  }
  let(:import_2_in) { BatchLoad::Import::Otus::DataAttributesInterpreter.new(project_id: project.id,
                                                                             user_id: user.id,
                                                                             file: upload_file_2,
                                                                             type_select: 'internal',
                                                                             source_id: source.id,
                                                                             create_new_predicate: 'on',
                                                                             create_new_otu: '1')
  }
  let(:import_no_new_predicate) { BatchLoad::Import::Otus::DataAttributesInterpreter.new(project_id: project.id,
                                                                                         user_id: user.id,
                                                                                         file: upload_file_2,
                                                                                         type_select: 'import',
                                                                                         create_new_otu: '1')
  }
  let(:import_no_source_id) { BatchLoad::Import::Otus::DataAttributesInterpreter.new(project_id: project.id,
                                                                                     user_id: user.id,
                                                                                     file: upload_file_2,
                                                                                     type_select: 'import'
  )
  }
  let(:import_no_new_otus) { BatchLoad::Import::Otus::DataAttributesInterpreter.new(project_id: project.id,
                                                                                    user_id: user.id,
                                                                                    file: upload_file_2,
                                                                                    type_select: 'import',
                                                                                    source_id: source.id)
  }
  let(:import_create_unmatched_otus) { BatchLoad::Import::Otus::DataAttributesInterpreter.new(project_id: project.id,
                                                                                              user_id: user.id,
                                                                                              file: upload_file_2,
                                                                                              type_select: 'import',
                                                                                              create_new_otu: '1')
  }

  # rubocop:disable Rails/SaveBang
  context 'scanning tsv lines to evaluate data' do
    context 'file provided' do
      it 'loads data for review' do
        names
        bingo = import_2_im
        expect(bingo).to be_truthy
      end

      context 'finds some errors' do
        specify 'of \'predicate\' type' do
          bingo = import_2_im
          expect(bingo.processed_rows[6].parse_errors.flatten).to include("No content for 'Predicate' was provided.")
        end

        specify 'of \'value\' type' do
          bingo = import_2_im
          expect(bingo.processed_rows[5].parse_errors.flatten).to include("No content for 'Value' was provided.")
        end

        specify 'of \'multiple otu\' type' do
          names
          Otu.create(name: 'Aus bus')
          bingo = import_2_im
          expect(bingo.processed_rows[1].parse_errors.flatten).to include("Can't resolve multiple found otus.")
        end

        specify 'of combination exists type' do
          names
          # this one matches one in the import_2_im file
          an_otu = Otu.create(name: 'Aus bus')
          a_da = ImportAttribute.new(import_predicate: 'TotalSpecies',
                                     value: 22)
          an_otu.data_attributes << a_da
          bingo = import_2_im
          expect(bingo.processed_rows[1].parse_errors.flatten)
              .to include('otu/predicate/value combination already exists.')
        end
      end

      context 'process non-error combinations' do
        let(:attribute_matches) {
          # this one matches one in the import_2_im file
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
            bingo = import_2_im
            bingo.create
            expect(Otu.count).to eq(start[:otus] + 4)
          end

          specify 'check data_attributes' do
            names # provides one otu Aus bus, without data_attribute
            attribute_matches # provides multiple matching attributes and ots
            start # check object count
            bingo = import_2_im
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
          bingo = import_2_im
          bingo.create
          # names creates 7 otus, and import_2_im finds one (not added), four new ones (two were not saved because of
          # errors in predicate or value)
          expect(Otu.count).to eq(11)
        end
      end

      context 'data_attribute count' do
        it 'loads reviewed data' do
          names
          bingo = import_2_im
          bingo.create
          expect(DataAttribute.count).to eq(5)
        end

        specify 'no otu creation attempted for error lines' do
          bingo = import_2_im
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
          bingo = import_2_im
          bingo.create
          # one data attribute is created here,
          # import_2_im creates four data attributes directly by otu name,
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
          bingo = import_2_im
          bingo.create
          # one data attribute is created here,
          # import_2_im creates four data attributes directly by otu name,
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
          bingo = import_create_unmatched_otus
          bingo.create
          expect(Otu.count).to eq(start + 4)
        end

        specify 'is false' do
          names
          start = Otu.count
          bingo = import_no_new_otus
          bingo.create
          expect(Otu.count).to eq(start)
        end
      end

      context 'create unmatched predicates' do
        let(:in_a) { DataAttribute.new(type: 'InternalAttribute',
                                       controlled_vocabulary_term_id: predicate.id,
                                       value: 'new data attribute for the otu',
                                       project_id: project.id) }
        let(:otu) { Otu.find_by_name('americana') }
        let(:t_n) { FactoryBot.create(:valid_taxon_name, {name: 'Taxonmatchidae'}) }
        let(:predicate) { FactoryBot.create(:valid_predicate, {name: 'Total Males'}) }

        before do
          names
          otu.data_attributes << in_a
          otu.taxon_name = t_n
          otu.save
        end

        specify 'is true' do
          start = Predicate.count
          bingo = import_2_in
          bingo.create
          expect(Predicate.count).to eq(start + 1)
        end

        specify 'is false' do
          start = Predicate.count
          bingo = import_no_new_predicate
          bingo.create
          expect(Predicate.count).to eq(start)
        end
      end

      context 'source id' do
        specify 'is specified' do
          bingo = import_2_im
          bingo.create
          expect(Citation.count).to eq(5)
        end

        specify 'is not specified' do
          bingo = import_no_source_id
          bingo.create
          expect(Citation.count).to eq(0)
        end
      end
    end
  end

  context 'testing import object' do

    let(:im_a) { DataAttribute.new(type: 'ImportAttribute',
                                   import_predicate: 'connection to otu',
                                   value: 'new data attribute for the otu',
                                   project_id: project.id) }
    let(:in_a) { DataAttribute.new(type: 'InternalAttribute',
                                   controlled_vocabulary_term_id: predicate.id,
                                   value: 'new data attribute for the otu',
                                   project_id: project.id) }
    let(:otu) { Otu.find_by_name('americana') }
    let(:t_n) { FactoryBot.create(:valid_taxon_name, {name: 'Taxonmatchidae'}) }
    let(:predicate) { FactoryBot.create(:valid_predicate, {name: 'Total Males'}) }

    before do
      names
      otu.data_attributes << im_a
      otu.data_attributes << in_a
      otu.taxon_name = t_n
      otu.save
    end

    context 'baseline' do
      specify 'otus' do
        expect(Otu.count).to eq(7)
      end

      specify 'import_attributes' do
        expect(ImportAttribute.count).to eq(1)
      end

      specify 'internal_attributes' do
        expect(InternalAttribute.count).to eq(1)
      end

      specify 'predicate' do
        expect(Predicate.count).to eq(1)
      end

      specify 'protonyms' do
        expect(Protonym.count).to eq(2)
      end
    end

    specify '.new succeeds' do
      expect(import_2_im).to be_truthy
    end

    specify '#processed_rows' do
      expect(import_2_im.processed_rows.count).to eq(8)
    end

    specify '#processed_rows' do
      expect(import_2_im.create_attempted).to eq(false)
    end

    context 'different data_attribute types' do
      context 'InternalAttribute' do
        context 'after .create' do
          before { import_2_in.create }

          specify '#create_attempted' do
            expect(import_2_in.create_attempted).to eq(true)
          end

          specify '#valid_objects' do
            expect(import_2_in.valid_objects.count).to eq(19)
          end

          specify '#successful_rows' do
            expect(import_2_in.successful_rows).to be_truthy
          end

          specify '#total_records_created' do
            expect(import_2_in.total_records_created).to eq(19)
          end
        end
      end

      context 'ImportAttribute' do
        context 'after .create' do
          before { import_2_im.create }

          specify '#create_attempted' do
            expect(import_2_im.create_attempted).to eq(true)
          end

          specify '#valid_objects' do
            expect(import_2_im.valid_objects.count).to eq(15)
          end

          specify '#successful_rows' do
            expect(import_2_im.successful_rows).to be_truthy
          end

          specify '#total_records_created' do
            expect(import_2_im.total_records_created).to eq(15)
          end
        end
      end
    end
  end
end
# rubocop:enable Rails/SaveBang
