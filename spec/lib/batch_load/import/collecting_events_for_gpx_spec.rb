require 'rails_helper'

describe BatchLoad::Import::CollectingEvents::GpxInterpreter, type: :model do

  let(:file_name) { 'spec/files/batch/collecting_event/test.gpx' }
  let(:upload_file) { fixture_file_upload(file_name) }

  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }

  let(:setup) {
    gpx = GPX::GPXFile.new(file_name)
  }

  let(:import) { BatchLoad::Import::CollectingEvents::GpxInterpreter.new(
    project_id: project.id,
    user_id: user.id,
    file: upload_file)
  }

  before { setup }

  specify 'baseline is 1' do
    xexpect(CollectingEvent.count).to eq(1)
    xexpect(GPX.count).to eq(1)
  end

  specify '.new succeeds' do
    xexpect(import).to be_truthy
  end

  specify '#processed_rows' do
    xexpect(import.processed_rows.count).to eq(8)
  end

  specify '#processed_rows' do
    xexpect(import.create_attempted).to eq(false)
  end

  context 'after .create' do
    before { import.create }

    specify '#create_attempted' do
      xexpect(import.create_attempted).to eq(true)
    end

    specify '#valid_objects' do
      xexpect(import.valid_objects.count).to eq(7)
    end

    specify '#successful_rows' do
      xexpect(import.successful_rows).to be_truthy
    end

    specify '#total_records_created' do
      xexpect(import.total_records_created).to eq(7)
    end
  end



end
