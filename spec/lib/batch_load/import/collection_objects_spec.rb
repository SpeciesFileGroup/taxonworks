require 'rails_helper'

describe BatchLoad::Import::CollectionObjects, type: :model do

  let(:file_name) { 'spec/files/batch/collection_object/CollectionObjectTest.tsv' }
  let(:setup) {
    @psuc = []
    csv1  = CSV.read(file_name, {headers: true, header_converters: :downcase, col_sep: "\t", encoding: "UTF-8"})
    csv1.each do |row1|
      @psuc.push(row1[1])
      FactoryGirl.create(:valid_identifier, namespace: ns_1, identifier: row1[1])
    end
  }
  let(:csv_args) { {headers: true, col_sep: "\t", encoding: 'UTF-8'} }

  let(:ns_1) { Namespace.create(name: 'PSUC', short_name: 'PSUC') }
  let(:ns_2) { Namespace.create(name: 'Import', short_name: 'Collecting Event No.') }
  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }

  let(:upload_file) { fixture_file_upload(file_name) }
  let(:import) {
    BatchLoad::Import::CollectionObjects.new(project_id: project.id,
                                             user_id:    user.id,
                                             file:       upload_file,
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
      ns_2
      bingo = import
      expect(bingo).to be_truthy
      expect(Otu.count).to eq(1)
      expect(Identifier.count).to eq(305) # one built above, one for each co in import
      expect(CollectingEvent.count).to eq(171)
      expect(Georeference.count).to eq(116)
    end
  end
end
