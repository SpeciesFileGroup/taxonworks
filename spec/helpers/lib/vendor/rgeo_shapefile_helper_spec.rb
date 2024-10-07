require 'rails_helper'

describe Lib::Vendor::RgeoShapefileHelper, type: :helper do
  let(:shp_doc) {
    Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + 'spec/files/shapefiles/four_valid_shapes.shp'),
        'application/x-shapefile'
      ))
  }
  let(:shx_doc) {
    Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + 'spec/files/shapefiles/four_valid_shapes.shx'),
        'application/x-shapefile'
      ))
  }
  let(:dbf_doc) {
    Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + 'spec/files/shapefiles/four_valid_shapes.dbf'),
        'application/x-dbf'
      ))
  }
  let(:prj_doc) {
    Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + 'spec/files/shapefiles/four_valid_shapes.prj'),
        'text/plain'
      ))
  }
  let(:shapefile) {
    # This one is all valid
    {
      shp_doc_id: shp_doc.id,
      shx_doc_id: shx_doc.id,
      dbf_doc_id: dbf_doc.id,
      prj_doc_id: prj_doc.id,
      name_field: 'Name'
    }
  }

  context 'validate_shape_file' do
    specify 'returns true on valid' do
      expect(validate_shape_file(shapefile)).to be true
    end

    specify 'crs must be GCS_WGS_1984' do
      not_wgs84 = Document.create!(
        document_file: Rack::Test::UploadedFile.new(
          (Rails.root + 'spec/files/shapefiles/not_wgs84.prj'),
          'text/plain'
        ))
      shapefile[:prj_doc_id] = not_wgs84.id

      expect(validate_shape_file(shapefile)).to include('GCS_WGS_1984')
    end

    specify 'name field must exist' do
      shapefile[:name_field] = 'ASDF'
      expect(validate_shape_file(shapefile)).to include('ASDF')
    end

    specify 'name field must have type String' do
      shapefile[:name_field] = 'Shape_STLe' # a numeric field
      expect(validate_shape_file(shapefile)).to include('String')
    end

    specify 'all records must have a name' do
      shapefile[:name_field] = 'FacilityID' # one record missing this name
      expect(validate_shape_file(shapefile)).to include('has no name')
    end
  end

  context 'fields_from_shapefile' do
    specify 'returns column names' do
      expect(fields_from_shapefile(dbf_doc.id))
        .to contain_exactly('Name', 'FacilityID', 'Status', 'Type',
          'Shape_STAr', 'Shape_STLe')
    end
  end

end