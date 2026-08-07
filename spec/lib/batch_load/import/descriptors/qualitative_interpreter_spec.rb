require 'rails_helper'

describe BatchLoad::Import::Descriptors::QualitativeInterpreter, type: :model, group: [:observation_matrix, :batch_load] do

  let(:file_name) { 'spec/files/batch/descriptor/qualitative_descriptors.tab' }
  let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }

  let(:import) { BatchLoad::Import::Descriptors::QualitativeInterpreter.new(
    project_id: Current.project_id,
    user_id: Current.user_id,
    file: upload_file)
  }

  specify 'import' do
    expect(import).to be_truthy
  end
end
