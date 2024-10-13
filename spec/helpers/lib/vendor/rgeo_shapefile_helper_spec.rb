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
  let(:project_id) { Current.project_id }

  context 'validate_shape_file' do
    specify 'does not raise on valid shapefile' do
      expect{validate_shape_file(shapefile, project_id)}.not_to raise_error
    end

    specify 'crs must be GCS_WGS_1984' do
      not_wgs84 = Document.create!(
        document_file: Rack::Test::UploadedFile.new(
          (Rails.root + 'spec/files/shapefiles/not_wgs84.prj'),
          'text/plain'
        ))
      # mini-hack to avoid more document-loading boilerplate
      not_wgs84.update!(document_file_file_name: prj_doc.document_file_file_name)
      shapefile[:prj_doc_id] = not_wgs84.id

      expect{validate_shape_file(shapefile, project_id)}
        .to raise_error(TaxonWorks::Error, /WGS 84/)
    end

    specify 'name field must exist' do
      shapefile[:name_field] = 'ASDF'
      expect{validate_shape_file(shapefile, project_id)}
        .to raise_error(TaxonWorks::Error, /ASDF/)
    end

    specify 'name field must have type String' do
      shapefile[:name_field] = 'Shape_STLe' # a numeric field
      expect{validate_shape_file(shapefile, project_id)}
        .to raise_error(TaxonWorks::Error, /String/)
    end

    specify 'all records must have a name' do
      shapefile[:name_field] = 'FacilityID' # one record missing this name
      expect{validate_shape_file(shapefile, project_id)}
        .to raise_error(TaxonWorks::Error, /has no name/)
    end

    context 'filling in unspecified files' do
      let!(:min_shapefile) {
        {
          shp_doc_id: shp_doc.id,
          name_field: 'Name'
        }
      }
      specify 'enough to specify a .shp file if the other docs exist' do
        [shx_doc, dbf_doc, prj_doc] # instantiate these
        expect{validate_shape_file(min_shapefile, project_id)}
          .not_to raise_error
      end

      specify '.shp document must be specified' do
        # i.e. we don't infer .shp from any of the others
        sf = {
          shx_doc_id: shx_doc.id,
          dbf_doc_id: dbf_doc.id,
          prj_doc_id: prj_doc.id,
          name_field: 'Name'
        }
        shp_doc
        expect{validate_shape_file(sf, project_id)}
          .to raise_error(TaxonWorks::Error, /.shp file is required/)
      end

      specify 'fail if an unspecified doc does not exist' do
        [shx_doc, dbf_doc]
        expect{validate_shape_file(min_shapefile, project_id)}
          .to raise_error(TaxonWorks::Error, /Failed to find/)
      end

      specify 'do not fail if a duplicate of a specified file exists' do
        # We don't warn of duplicates on files users explicitly choose
        # themselves (even though they could be unknowingly choosing the wrong
        # one)
        Document.create!(
          document_file: Rack::Test::UploadedFile.new(
            (Rails.root + 'spec/files/shapefiles/four_valid_shapes.shp'),
            'application/x-shapefile'
        ))
        [shx_doc, dbf_doc, prj_doc]
        expect{validate_shape_file(min_shapefile, project_id)}
          .not_to raise_error
      end

      specify 'fail if multiple unspecified docs with the same name exist' do
        Document.create!(
          document_file: Rack::Test::UploadedFile.new(
            (Rails.root + 'spec/files/shapefiles/four_valid_shapes.shx'),
            'application/x-shapefile'
        ))
        [shx_doc, dbf_doc, prj_doc]
        expect{validate_shape_file(min_shapefile, project_id)}
          .to raise_error(TaxonWorks::Error, /More than one/)
      end

    end
  end

  context 'fields_from_shapefile' do
    specify 'returns column names given a dbf_doc_id' do
      expect(fields_from_shapefile(nil, dbf_doc.id, project_id))
        .to contain_exactly('Name', 'FacilityID', 'Status', 'Type',
          'Shape_STAr', 'Shape_STLe')
    end

    specify 'returns column names given a shp_doc_id' do
      dbf_doc
      expect(fields_from_shapefile(shp_doc.id, nil, project_id))
        .to contain_exactly('Name', 'FacilityID', 'Status', 'Type',
          'Shape_STAr', 'Shape_STLe')
    end

    specify 'raises error if no unspecified dbf match exists' do
      expect{fields_from_shapefile(shp_doc.id, nil, project_id)}
        .to raise_error(TaxonWorks::Error, /No/)
    end

    specify 'raises error if multiple unspecified dbf matches exist' do
      dbf_doc
      Document.create!(
        document_file: Rack::Test::UploadedFile.new(
          (Rails.root + 'spec/files/shapefiles/four_valid_shapes.dbf'),
          'application/x-shapefile'
      ))
      expect{fields_from_shapefile(shp_doc.id, nil, project_id)}
        .to raise_error(TaxonWorks::Error, /Multiple/)
    end
  end

end