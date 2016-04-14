require 'rails_helper'

describe BatchLoad::Import::CollectionObjects, type: :model do

  let(:file_name) { 'spec/files/batch/collection_object/CollectionObjectTest.txt' }
  let(:psuc) { [0, 35614, 39024, 37926, 38919, 38866, 35628, 39770, 35423, 40857, 35397, 35467, 35463,
                35553, 35401, 35543, 40893, 35441, 37991, 35382, 35406, 39509, 35399, 35352, 41614, 42247, 84016,
                35404, 39866, 35530, 37881, 35600, 35599, 35465, 41861, 39887, 35531, 42578, 40112, 39785, 35550,
                83845, 41495, 39796, 39771, 35479, 35484, 35384, 42317, 35509, 35554, 35388, 37871, 35369, 42676,
                41511, 35416, 35372, 35510, 35445, 35529, 35429, 40729, 35591, 39141, 38889, 42326, 39172, 35552,
                38982, 39178, 39055, 40131, 35561, 42738, 39042, 40062, 39090, 38863, 38933, 35592, 39179, 39128,
                35652, 39136, 91776, 39019, 39195, 40064, 38936, 40140, 38987, 38123, 40056, 39058, 38880, 39078,
                38996, 37983, 40167, 37979, 38998, 42772, 40120, 38993, 39897, 38963, 39111, 35581, 39048, 35492,
                35588, 43043, 35648, 35693, 35646, 35578, 40122, 39082, 38873, 35459, 40901, 35612, 36751, 35482,
                98958, 98173, 95290, 92347, 35054, 38857, 38859, 40034, 37936, 39056, 84644, 91941, 85029, 91969,
                98842, 91909, 39121, 38948, 38961, 38974, 40046, 39080, 35095, 37052, 39197, 91889, 98946, 92089,
                98889, 85047, 84978, 39050, 98726, 40123, 35590, 39763, 38108, 35645, 98450, 92007, 84504, 99034,
                98768, 84134, 91923, 85027, 84789, 98220, 91550, 82020, 99046, 36935, 92025, 91877, 85009, 85043,
                36359, 36211, 42469, 91879, 85016, 84219, 35115, 84919, 98828, 91935, 99043, 39091, 38876, 35573,
                38926, 98718, 35383, 38870, 35597, 37810, 38907, 38981, 38865, 38122, 39073, 39087, 36735, 92228]
  }
  let(:csv_args) { {headers: true, col_sep: "\t", encoding: 'UTF-8'} }

  let(:ns_1) { Namespace.create(name: 'PSUC', short_name: 'PSUC') }
  let(:ns_2) { Namespace.create(name: 'Import', short_name: 'Collecting Event No.') }
  let(:co_1) { id_1.identifier_object }
  let(:id_1) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[1]) }
  let(:co_2) { id_2.identifier_object }
  let(:id_2) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[2]) }
  let(:co_3) { id_3.identifier_object }
  let(:id_3) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[3]) }
  let(:co_4) { id_4.identifier_object }
  let(:id_4) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[4]) }
  let(:co_5) { id_5.identifier_object }
  let(:id_5) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[5]) }
  let(:co_6) { id_6.identifier_object }
  let(:id_6) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[6]) }
  let(:co_7) { id_7.identifier_object }
  let(:id_7) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[7]) }
  let(:co_8) { id_8.identifier_object }
  let(:id_8) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[8]) }
  let(:co_9) { id_9.identifier_object }
  let(:id_9) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[9]) }
  let(:co_10) { id_10.identifier_object }
  let(:id_10) { FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: psuc[10]) }
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
      co_1
      co_2
      co_3
      co_4
      co_5
      co_6
      co_7
      co_8
      co_9
      bingo = import
      expect(bingo).to be_truthy
      # expect(Namespace.count).to eq(2)
      expect(Otu.count).to eq(1)
      expect(Identifier.count).to eq(18) # one built above, one for each co in import
      expect(CollectingEvent.count).to eq(9)
    end
  end
end
