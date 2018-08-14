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

  let(:upload_file_2) { fixture_file_upload(file_ph_2) }
  let(:import_2) { BatchLoad::Import::Otus::DataAttributesInterpreter.new(project_id: project.id,
                                                                          user_id: user.id,
                                                                          file: upload_file_2)
  }

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
          expect(bingo.processed_rows[5].parse_errors.flatten).to include("No contents for 'Predicate' was provided.")
        end

        specify 'of \'value\' type' do
          bingo = import_2
          expect(bingo.processed_rows[4].parse_errors.flatten).to include("No contents for 'Value' was provided.")
        end

        specify 'of \'multiple otu\' type' do
          names
          Otu.create(name: 'Aus bus')
          bingo = import_2
          expect(bingo.processed_rows[1].parse_errors.flatten).to include("Can't resolve multiple otus.")
        end

        specify 'of \'combination exists\' type' do
          names
          an_otu = Otu.create(name: 'Aus bus')
          a_da = ImportAttribute.new(import_predicate: 'TotalSpecies',
                                     value: 22)
          an_otu.data_attributes << a_da
          an_otu = Otu.create(name: 'Nuther bus')
          a_da = ImportAttribute.new(import_predicate: 'TotalSpecies',
                                     value: 22)
          an_otu.data_attributes << a_da
          bingo = import_2
          expect(bingo.processed_rows[1].parse_errors.flatten)
              .to include('otu/predicate/value combination already exists.')
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
          # names creates 7 otus, and import_2 finds one (not added), two new ones (two were not saved because of
          # errors in predicate or value)
          expect(Otu.count).to eq(10)
        end
      end

      context 'data_attribute count' do
        it 'loads reviewed data' do
          names
          bingo = import_2
          bingo.create
          expect(DataAttribute.count).to eq(4)
        end

        specify 'no otu creation attempted for error lines' do
          bingo = import_2
          bingo.create
          expect(Otu.count).to eq(4)
        end
      end
    end

    context 'match to taxon name, not otu' do
      context 'otu check' do
        let(:d_a) { DataAttribute.new(type: 'ImportAttribute',
                                      import_predicate: 'connection to otu',
                                      value: 'new data attribute for the otu',
                                      project_id: project.id) }
        let(:otu) { Otu.find_by_name('americana') }
        let(:t_n) { TaxonName.create(name: 'taxon match') }

        it 'finds otu through taxon name' do
          names
          otu.data_attributes << d_a
          otu.taxon_name = t_n
          bingo = import_2
          bingo.create
          # one data attribute is created here,
          # import_2 creates four data attributes directly by otu name,
          # and one by reference to a taxon_name
          expect(DataAttribute.count).to eq(5)
        end
      end
    end
  end
end
