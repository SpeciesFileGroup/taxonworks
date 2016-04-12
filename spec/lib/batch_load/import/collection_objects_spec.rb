require 'rails_helper'

describe BatchLoad::Import::CollectionObjects, type: :model do

  let(:file_name) { 'spec/files/batch/collection_object/CollectionObjectTest.txt' }
  let(:csv_args) { {headers: true, col_sep: "\t", encoding: 'UTF-8'} }
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
      bingo = import
      expect(bingo).to be_truthy
      expect(Namespace.count).to eq(1)
      expect(Otu.count).to eq(1)
    end
  end
end
