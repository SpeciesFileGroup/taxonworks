require 'rails_helper'

describe BatchLoad::Import::CollectionObjects::BufferedInterpreter, type: :model do
  let(:file_name) { 'spec/files/batch/collection_object/co_from_strings.tsv' }
  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }
  let(:source) { FactoryBot.create(:valid_source_verbatim) }
  let(:otu) { FactoryBot.create(:valid_otu) }

  let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }
  let(:import) { BatchLoad::Import::CollectionObjects::BufferedInterpreter.new(**params)
  }

  let(:params) { {project_id: project_id,
                  user_id: user_id,
                  file: upload_file} }

  context 'scanning tsv lines to evaluate data' do
    context 'file provided' do
      it 'loads data for review' do
        bingo = import
        expect(bingo).to be_truthy
      end
    end

    context 'find some errors' do
      specify 'of the type \'No strings\'' do
        bingo = import
        expect(bingo.processed_rows[8].parse_errors).to include('No strings provided for any buffered data.')
      end
    end

    context 'process non-error csv lines' do
      context 'without source or otu' do
        specify 'specimens without source or otu' do
          bingo = import
          bingo.create
          expect(Specimen.count).to eq(7)
        end

        specify 'taxon_determinination otu' do
          bingo = import
          bingo.create
          expect(TaxonDetermination.count).to eq(0)
        end

        specify 'citation without source' do
          bingo = import
          bingo.create
          expect(Citation.count).to eq(0)
        end
      end

      context 'processing source_id' do
        specify 'specimens with source' do
          params.merge!(source_id:  source.id)
          bingo = import
          bingo.create
          expect(Specimen.count).to eq(7)
        end

        specify 'citations with source' do
          params.merge!(source_id:  source.id)
          bingo = import
          bingo.create
          expect(Citation.count).to eq(7)
        end
      end

      context 'processing otu_id' do
        specify 'specimens with otu' do
          params.merge!(otu_id: otu.id)
          bingo = import
          bingo.create
          expect(Specimen.count).to eq(7)
        end

        specify 'taxon_determinations with otu' do
          params.merge!(otu_id: otu.id)
          bingo = import
          bingo.create
          expect(TaxonDetermination.count).to eq(7)
        end
      end

      context 'processing source_id and otu_id' do
        specify 'specimens with otu and source' do
          params.merge!(otu_id: otu.id, source_id:  source.id)
          bingo = import
          bingo.create
          expect(Specimen.count).to eq(7)
        end

        specify 'taxon_determinations with otu and source' do
          params.merge!(otu_id: otu.id, source_id:  source.id)
          bingo = import
          bingo.create
          expect(TaxonDetermination.count).to eq(7)
        end

        specify 'citations with source and otu' do
          params.merge!(otu_id: otu.id, source_id:  source.id)
          bingo = import
          bingo.create
          expect(Citation.count).to eq(7)
        end
      end
    end
  end
end
