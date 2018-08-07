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
                                             user_id:    user.id,
                                             file:       upload_file)
  }

  let(:upload_file_2) { fixture_file_upload(file_ph_2) }
  let(:import_2) { BatchLoad::Import::Otus::DataAttributesInterpreter.new(project_id: project.id,
                                                                          user_id:    user.id,
                                                                          file:       upload_file_2)
  }

  context 'scanning tsv lines to evaluate data' do

    context 'file provided' do
      it 'loads reviewed data' do
        names
        bingo = import_2
        expect(bingo).to be_truthy
      end
    end
  end

  context 'building objects from valid tsv lines' do

    context 'file provided' do
      context 'otu count' do
        it 'loads reviewed data' do
          names
          bingo = import_2
          bingo.create
          expect(Otu.count).to eq(7)
        end
      end

      context 'data_attribute count' do
        it 'loads reviewed data' do
          names
          bingo = import_2
          bingo.create
          expect(DataAttribute.count).to eq(3)
        end
      end
    end
  end
end
