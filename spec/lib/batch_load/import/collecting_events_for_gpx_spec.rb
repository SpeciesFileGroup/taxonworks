require 'rails_helper'

describe BatchLoad::Import::CollectingEvents::GPXInterpreter, type: :model, group: [:geo, :collecting_events] do

  let(:file_name) { 'spec/files/batch/collecting_event/test.gpx' }
  let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }

  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }

  # let(:setup) {
  #   gpx = GPX::GPXFile.new(file_name)
  # }

  let(:import) { BatchLoad::Import::CollectingEvents::GPXInterpreter.new(
    project_id: project.id,
    user_id: user.id,
    file: upload_file)
  }

  # before { setup }

  specify 'baseline is 0' do
    expect(CollectingEvent.count).to eq(0)
    expect(Georeference::GPX.count).to eq(0)
    expect(GeographicItem::Point.count).to eq(0)
    expect(GeographicItem::LineString.count).to eq(0)
  end

  specify '.new succeeds' do
    expect(import).to be_truthy
  end

  specify '#processed_rows' do
    expect(import.processed_rows.count).to eq(2)
  end

  specify '#processed_rows' do
    expect(import.create_attempted).to eq(false)
  end

  context 'after .create' do
    before { import.create }

    specify '#create_attempted' do
      expect(import.create_attempted).to eq(true)
    end

    specify '#valid_objects' do
      expect(import.valid_objects.count).to eq(2)
    end

    specify '#successful_rows' do
      expect(import.successful_rows).to be_truthy
    end

    specify '#total_records_created' do
      expect(import.total_records_created).to eq(2)
    end

    context 'creating actual objects' do
      specify 'collecting_events' do
        expect(CollectingEvent.count).to eq(2)
      end

      specify 'georeferences' do
        expect(Georeference::GPX.count).to eq(2)
      end

      context 'geographic_items' do
        specify 'point' do
          expect(GeographicItem::Point.count).to eq(1)
        end

        specify 'line_string' do
          expect(GeographicItem::LineString.count).to eq(1)
        end
      end
    end
  end
end
