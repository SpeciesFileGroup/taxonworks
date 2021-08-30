require 'rails_helper'
require 'batch_load/import/collection_objects'

describe BatchLoad::Import::CollectionObjects, type: :model do

  let!(:ns_1) { Namespace.create!(name: 'PSUC', short_name: 'PSUC') }
  let!(:ns_2) { Namespace.create!(name: 'Import', short_name: 'Collecting Event No.') }

  context 'scanning tsv lines to evaluate data' do
    let(:file_name) { 'spec/files/batch/collection_object/CollectionObjectTestErr.tsv' }
    let(:setup) {
      csv1 = CSV.read(file_name, headers: true, header_converters: :downcase, col_sep: "\t", encoding: 'UTF-8')
      csv1.each do |row|
        ident = row[1]
        # the following invocation also creates a valid specimen as a collection_object
        id_er = FactoryBot.create(:valid_identifier, namespace: ns_1, identifier: ident)
        co    = id_er.identifier_object
        case ident
        when '35397' # create a collecting event to find later
          error = (row['error'].to_s + ' ' + row['georeference_error_units'].to_s).strip
          ns_ce = Namespace.where(short_name: row['collecting_event_identifier_namespace_short_name']).first
          ce = FactoryBot.create(
            :valid_collecting_event,
            {verbatim_locality: row['verbatim_location'],
             verbatim_geolocation_uncertainty:    error.empty? ? nil : error,
             start_date_day:          row['start_day'],
             start_date_month:        row['start_month'],
             start_date_year:         row['start_year'],
             end_date_day:            row['end_day'],
             end_date_month:          row['end_month'],
             end_date_year:           row['end_year'],
             verbatim_longitude:      row['longitude'],
             verbatim_latitude:       row['latitude'],
             verbatim_method:         row['method'],
             verbatim_date:           row['verbatim_date'],
             verbatim_elevation:      nil,
             project_id:              project.id,
             identifiers_attributes:  [{namespace:  ns_ce,
                                                    project_id: project.id,
                                                    type:       'Identifier::' + row['collecting_event_identifier_type'],
                                                    identifier: row['collecting_event_identifier_identifier']}],
          geo_locate_georeferences_attributes: [{iframe_response: "#{row['latitude']}|#{row['longitude']}|#{Utilities::Geo.distance_in_meters(error).to_f}|Unavailable"}]
          }
          )

          co.collecting_event = ce
          co.save
          gr1   = Georeference::VerbatimData.create(collecting_event: ce)
          # gr2   = Georeference::GeoLocate.new(collecting_event: ce, iframe_response:
          # "#{row['latitude']}|#{row['longitude']}|#{Utilities::Geo.elevation_in_meters(error)}|Unavailable")
        when '38866' # create a collecting event to find later
          error = (row['error'].to_s + ' ' + row['georeference_error_units'].to_s).strip
          ns_ce = Namespace.where(short_name: row['collecting_event_identifier_namespace_short_name']).first
          ce = FactoryBot.create(
            :valid_collecting_event,
            {verbatim_locality:                   row['verbatim_location'],
             verbatim_geolocation_uncertainty:    error.empty? ? nil : error,
             start_date_day:                      row['start_day'],
             start_date_month:                    row['start_month'],
             start_date_year:                     row['start_year'],
             end_date_day:                        row['end_day'],
             end_date_month:                      row['end_month'],
             end_date_year:                       row['end_year'],
             verbatim_longitude:                  row['longitude'],
             verbatim_latitude:                   row['latitude'],
             verbatim_method:                     row['method'],
             verbatim_date:                       row['verbatim_date'],
             verbatim_elevation:                  nil,
             project_id:                          project.id,
             identifiers_attributes:              [{namespace:  ns_ce,
                                                    project_id: project.id,
                                                    type:       'Identifier::' + row['collecting_event_identifier_type'],
                                                    identifier: row['collecting_event_identifier_identifier']}],
          geo_locate_georeferences_attributes: [{iframe_response: "#{row['latitude']}|#{row['longitude']}|#{Utilities::Geo.distance_in_meters(error).to_f}|Unavailable"}]
          }
          )
          co.collecting_event = ce
          co.save
            gr1                 = Georeference::VerbatimData.create(collecting_event: ce)
          else
        end
      end
    }
    let(:csv_args) { {headers: true, col_sep: "\t", encoding: 'UTF-8'} }

    let(:user) { User.find(1) }
    let(:project) { Project.find(1) }

    let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }
    let(:evaluate) {
      BatchLoad::Import::CollectionObjects::new(
        project_id: project.id,
        user_id:    user.id,
        file:       upload_file,
        user_header_map:
        {'otu'         => 'otu_name',
         'start_day'   => 'start_date_day',
         'start_month' => 'start_date_month',
         'start_year'  => 'start_date_year',
         'end_day'     => 'end_date_day',
         'end_month'   => 'end_date_month',
         'end_year'    => 'end_date_year'},
      )
    }

    context 'file provided scans provided data data' do
      before { setup }
      it '1' do
        expect(evaluate).to be_truthy
      end

      it '2' do
        expect(evaluate.total_lines).to eq(208)
      end

      it '3' do
        expect(evaluate.processed_rows[1].parse_errors).to include('No collection object with cached identifier \'MuleDeer 35614\' exists.')
      end

      it '4' do
        expect(evaluate.processed_rows[11].parse_errors).to include('Collecting event problems: identifiers.identifier: 58170 already taken: ')
      end

      it '5' do
        expect(evaluate.processed_rows[16].parse_errors).to include('No available namespace \'MuleDear\'.', 'Collecting event problems: identifiers.namespace_id: can\'t be blank: ')
      end

      it '6' do
        expect(evaluate.processed_rows[61].objects[:ce].first.verbatim_locality).to eq('Collecting Event No. 59353')
      end
    end
  end

  context 'building objects from valid tsv lines' do
    let(:file_name) { 'spec/files/batch/collection_object/CollectionObjectTest.tsv' }
    let(:setup) {
      csv1 = CSV.read(file_name, headers: true, header_converters: :downcase, col_sep: "\t", encoding: 'UTF-8')
      csv1.each do |row|
        ident = row[1]
        case ident
          when '35397' # create a collecting event to find later
            error = (row['error'].to_s + ' ' + row['georeference_error_units'].to_s).strip
            ns_ce = Namespace.where(short_name: row['collecting_event_identifier_namespace_short_name']).first
            ce = FactoryBot.create(
              :valid_collecting_event,
              {verbatim_locality:                   row['verbatim_location'],
               verbatim_geolocation_uncertainty:    error.empty? ? nil : error,
               start_date_day:                      row['start_day'],
               start_date_month:                    row['start_month'],
               start_date_year:                     row['start_year'],
               end_date_day:                        row['end_day'],
               end_date_month:                      row['end_month'],
               end_date_year:                       row['end_year'],
               verbatim_longitude:                  row['longitude'],
               verbatim_latitude:                   row['latitude'],
               verbatim_method:                     row['method'],
               verbatim_date:                       row['verbatim_date'],
               verbatim_elevation:                  nil,
               project_id:                          project.id,
               identifiers_attributes:              [{namespace:  ns_ce,
                                                      project_id: project.id,
                                                      type:       'Identifier::' + row['collecting_event_identifier_type'],
                                                      identifier: row['collecting_event_identifier_identifier']}],
            geo_locate_georeferences_attributes: [{iframe_response: "#{row['latitude']}|#{row['longitude']}|#{Utilities::Geo.distance_in_meters(error).to_f}|Unavailable"}]
                                       }
            )
            gr1 = Georeference::VerbatimData.create(collecting_event: ce)
          else
        end
        # the following invocation also creates a valid specimen as a collection_object
        FactoryBot.create(:valid_identifier, namespace: ns_1, identifier: ident)
      end
    }

    let(:csv_args) { {headers: true, col_sep: "\t", encoding: 'UTF-8'} }
    let(:user) { User.find(1) }
    let(:project) { Project.find(1) }

    let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }
    let(:import) {
      BatchLoad::Import::CollectionObjects::new(
        project_id: project.id,
        user_id: user.id,
        file: upload_file,
        user_header_map:
        {'otu'         => 'otu_name',
         'start_day'   => 'start_date_day',
         'start_month' => 'start_date_month',
         'start_year'  => 'start_date_year',
         'end_day'     => 'end_date_day',
         'end_month'   => 'end_date_month',
         'end_year'    => 'end_date_year'}
      )
    }

    context 'file provided' do
      it 'loads reviewed data' do
        setup
        bingo = import
        expect(bingo).to be_truthy
        bingo.create
        expect(Otu.count).to eq(1)
        expect(Identifier.count).to eq(304) # one built above, one for each co in import
        expect(CollectingEvent.count).to eq(140)
        expect(Georeference.count).to eq(65)
        expect(bingo.processed_rows[61].objects[:ce].first.verbatim_locality).to eq('Collecting Event No. 59353')
      end
    end
  end
end
