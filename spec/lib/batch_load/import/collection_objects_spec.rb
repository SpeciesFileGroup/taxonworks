require 'rails_helper'

describe BatchLoad::Import::CollectionObjects, type: :model do

  let(:file_name) { 'spec/files/batch/collection_object/CollectionObjectTest.txt' }
  let(:psuc) { [0, 35614, 39024, 37926, 38919, 38866, 35628, 39770, 35423] }
  let(:csv_args) { {headers: true, col_sep: "\t", encoding: 'UTF-8'} }
  let(:ns_1) { Namespace.create(name: 'PSUC', short_name: 'PSUC') }
  let(:ns_2) { Namespace.create(name: 'Import', short_name: 'Collecting Event No.') }
  let(:co_1) { FactoryGirl.create(:valid_collection_object) }
  let(:id_1) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[1]) }
  let(:co_2) { FactoryGirl.create(:valid_collection_object) }
  let(:id_2) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[2]) }
  let(:co_3) { FactoryGirl.create(:valid_collection_object) }
  let(:id_3) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[3]) }
  let(:co_4) { FactoryGirl.create(:valid_collection_object) }
  let(:id_4) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[4]) }
  let(:co_5) { FactoryGirl.create(:valid_collection_object) }
  let(:id_5) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[5]) }
  let(:co_6) { FactoryGirl.create(:valid_collection_object) }
  let(:id_6) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[6]) }
  let(:co_7) { FactoryGirl.create(:valid_collection_object) }
  let(:id_7) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[7]) }
  let(:co_8) { FactoryGirl.create(:valid_collection_object) }
  let(:id_8) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[8]) }
  let(:co_9) { FactoryGirl.create(:valid_collection_object) }
  let(:id_9) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[0]) }
  # let(:basic_headers) { ['PSUC', 'Species', 'OTU', 'Confirmed?', 'Collecting Event#',
  #                        'Date', 'Month', 'Day', 'Year',
  #                        'Verbatim Location',
  #                        'Latitude', 'Longitude', 'Error', 'Method'] }
  # let(:basic_csv) {
  #   CSV.generate(options = csv_args) do |csv|
  #     csv << basic_headers
  #     csv << ['35614', 'Hetaerina americana', 'Hetaerina americana', '', '367',
  #             '8.18.1941', '8', '18', '1941',
  #             'Creek on Mary Shannon\'s place, Dallas, Texas',
  #             '', '', '', '']
  #     csv << ['37926', 'Hetaerina americana', 'Hetaerina americana', '', '2570',
  #             '7.30.1950', '7', '30', '1950',
  #             'Fish Hatchery, Kerrville, Tex.',
  #             '30.047433', '-99.140319', '10339 m', 'GEOLocate']
  #     csv
  #   end
  # }

  # let(:basic_csv_name_count) { 11 }

  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }
  # let(:parent_taxon_name) { FactoryGirl.create(:root_taxon_name) }
  # let(:iczn_family) { Protonym.create!(name: 'Aidae', rank_class: Ranks.lookup(:iczn, 'family'), parent: parent_taxon_name) }

  let(:upload_file) { fixture_file_upload(file_name) }
  let(:import) {
    BatchLoad::Import::CollectionObjects.new(project_id: project.id, user_id: user.id, file: upload_file)
  }

  context 'initialzation' do
    it 'begins to take form' do
      ns_2
      co_1.identifiers << id_1
      co_2.identifiers << id_2
      co_3.identifiers << id_3
      co_4.identifiers << id_4
      co_5.identifiers << id_5
      co_6.identifiers << id_6
      co_7.identifiers << id_7
      co_8.identifiers << id_8
      co_9.identifiers << id_9
      bingo = import
      expect(bingo).to be_truthy
      expect(Namespace.count).to eq(2)
      expect(Otu.count).to eq(1)
    end
  end
end
