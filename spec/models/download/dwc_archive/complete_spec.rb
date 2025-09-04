require 'rails_helper'

RSpec.describe Download::DwcArchive::Complete, type: :model do
  include ActiveJob::TestHelper

  before(:each) {
    Project.first.set_complete_dwc_eml_preferences(
      '<alternateIdentifier>ABC123</alternateIdentifier>\n<title xmlns:lang="en">Polka funk</title>',
      '<metadata>\n  <gbif>\n    <dateStamp>my_date_stamp</dateStamp>\n  </gbif>\n</metadata>'
    )
  }

  specify '#is_public defaults true' do
    a = Download::DwcArchive::Complete.new
    a.save!
    expect(a.is_public).to eq(true)
  end

  specify 'init' do
    expect(Download::DwcArchive::Complete.new.save!).to be_truthy
  end

  context 'with data' do
    let(:project) { Project.first }
    let!(:ce) { FactoryBot.create(:valid_collecting_event) }
    let!(:co) { Specimen.create!(collecting_event: ce) }
    let(:p1) { FactoryBot.create(:valid_predicate) }
    let(:p2) { FactoryBot.create(:valid_predicate) }
    let(:co_da) { InternalAttribute.create!(
      attribute_subject: co, controlled_vocabulary_term_id: p1.id, value: 'Io'
    ) }
    let(:ce_da) { InternalAttribute.create!(
      attribute_subject: ce, controlled_vocabulary_term_id: p2.id, value: 'Callisto'
    ) }

    specify 'download includes expected number of rows' do
      Specimen.create!
      Download::DwcArchive::Complete.create!
      perform_enqueued_jobs
      tbl = Spec::Support::Utilities::Dwca.extract_data_tsv_table(Download.first.file_path)
      expect(tbl.size).to eq(2) # doesn't include header row
    end

    specify 'download includes some headers' do
      Download::DwcArchive::Complete.new.save!
      perform_enqueued_jobs
      tbl = Spec::Support::Utilities::Dwca.extract_data_tsv_table(Download.first.file_path)
      expect(tbl.headers).to include('basisOfRecord', 'occurrenceID')
    end

    specify 'download includes some data' do
      Download::DwcArchive::Complete.new.save!
      perform_enqueued_jobs
      tbl = Spec::Support::Utilities::Dwca.extract_data_tsv_table(Download.first.file_path)
      expect(tbl.first['basisOfRecord']).to eq('PreservedSpecimen')
    end

    specify 'download includes data attribute columns' do
      [co_da, ce_da]
      project.set_complete_dwc_download_predicates({
        collection_object_predicate_id: [p1.id],
        collecting_event_predicate_id: [p2.id]
      })
      Download::DwcArchive::Complete.create!

      perform_enqueued_jobs

      co_predicate_header = 'TW:DataAttribute:CollectionObject:' + p1.name
      ce_predicate_header = 'TW:DataAttribute:CollectingEvent:' + p2.name

      tbl = Spec::Support::Utilities::Dwca.extract_data_tsv_table(Download.first.file_path)
      expect(tbl.headers).to include(co_predicate_header, ce_predicate_header)
    end

    specify 'download includes data attribute values' do
      [co_da, ce_da]
      project.set_complete_dwc_download_predicates({
        collection_object_predicate_id: [p1.id],
        collecting_event_predicate_id: [p2.id]
      })
      Download::DwcArchive::Complete.create!

      perform_enqueued_jobs

      co_predicate_header = 'TW:DataAttribute:CollectionObject:' + p1.name
      ce_predicate_header = 'TW:DataAttribute:CollectingEvent:' + p2.name

      tbl = Spec::Support::Utilities::Dwca.extract_data_tsv_table(Download.first.file_path)

      expect(tbl.first[co_predicate_header]).to eq('Io')
      expect(tbl.first[ce_predicate_header]).to eq('Callisto')
    end
  end
end

