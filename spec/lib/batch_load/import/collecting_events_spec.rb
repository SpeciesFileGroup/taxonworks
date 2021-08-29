require 'rails_helper'
require 'batch_load/import/collection_objects'

describe BatchLoad::Import::CollectionObjects, type: :model do

  # see ./colletcing_events_spec
  # let(:file_name) { 'spec/files/batch/collecting_event/CollectingEventTest.tsv' }
  # let(:setup) {
  #   @psuc = []
  #   csv1  = CSV.read(file_name, {headers: true, header_converters: :downcase, col_sep: "\t", encoding: "UTF-8"})
  #   csv1.each do |row1|
  #     @psuc.push(row1[1])
  #     FactoryBot.create(:valid_identifier, namespace: ns_1, identifier: row1[1])
  #   end
  # }
  # let(:csv_args) { {headers: true, col_sep: "\t", encoding: 'UTF-8'} }
  #
  # let(:ns_1) { Namespace.create(name: 'PSUC', short_name: 'PSUC') }
  # let(:ns_2) { Namespace.create(name: 'Import', short_name: 'Collecting Event No.') }
  # let(:user) { User.find(1) }
  # let(:project) { Project.find(1) }
  #
  # let(:upload_file) { Rack::Test::UploadedFile.new(file_name) }
  # let(:import) {
  #   BatchLoad::Import::CollectingEvents.new(project_id: project.id, user_id: user.id, file: upload_file)
  # }
  #
  # context 'initialzation' do
  #   it 'begins to take form' do
  #     setup
  #     ns_2
  #     bingo = import
  #     expect(bingo).to be_truthy
  #     expect(Otu.count).to eq(1)
  #     expect(Identifier.count).to eq(305) # one built above, one for each co in import
  #     expect(CollectingEvent.count).to eq(171)
  #     expect(Georeference.count).to eq(116)
  #   end
  # end
end
