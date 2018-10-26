require 'rails_helper'

describe BatchLoad::Import::CollectionObjects::BufferedInterpreter, type: :model do
  let(:file_name) { 'spec/files/batch/collection_object/co_from_strings.tsv' }
  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }
  let(:source) { FactoryBot.create(:valid_source_verbatim) }

  let(:upload_file) { fixture_file_upload(file_name) }
  let(:import) { BatchLoad::Import::CollectionObjects::BufferedInterpreter.new(params)
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
      specify 'specimens' do
        params.merge({source_id: source.id})
        bingo = import
        expect(bingo.objects[:specimen].count).to eq(7)
      end

      specify 'citations' do
        params.merge({source_id: source.id})
        bingo = import
        expect(bingo.objects[:citation].count).to eq(7)
      end
    end
  end
end
