require 'rails_helper'

RSpec.describe Download::DwcArchive::Complete, type: :model do
  include ActiveJob::TestHelper

  specify 'fails without EML set' do
    expect{Download::DwcArchive::Complete.new.save!}
      .to raise_error(ActiveRecord::RecordInvalid, /EML.*STUB/)
  end

  context 'with eml set' do
    before(:each) {
      # Requires EML without 'STUB's
      Project.first.set_complete_dwc_eml_preferences(
        '<alternateIdentifier>ABC123</alternateIdentifier>\n<title xmlns:lang="en">Polka funk</title>',
        '<metadata>\n  <gbif>\n    <dateStamp></dateStamp>\n    <emojiForTheSoul>:D</emojiForTheSoul>  </gbif>\n</metadata>'
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

    specify 'only one download allowed' do
      Download::DwcArchive::Complete.create!
      expect{Download::DwcArchive::Complete.create!}
        .to raise_error(ActiveRecord::RecordInvalid, /Only one/)
    end

    specify 'uses EML set by user in project' do
      Download::DwcArchive::Complete.create!
      perform_enqueued_jobs
      eml = Spec::Support::Utilities::Dwca.extract_eml_file(Download.first.file_path)
      expect(eml.at_xpath('//title').text).to eq('Polka funk')
      expect(eml.at_xpath('//emojiForTheSoul').text).to eq(':D')
    end

    specify 'uses EML attribute values set by TW' do
      Download::DwcArchive::Complete.create!
      perform_enqueued_jobs
      eml = Spec::Support::Utilities::Dwca.extract_eml_file(Download.first.file_path)
      # "434169b8-a838-46ec-86e6-cbc4f814b8b8"
      expect(eml.at_xpath('//alternateIdentifier').text).to match(/\A([a-zA-Z0-9]+-){4}[a-zA-Z0-9]+\z/)
      expect(Time.parse(eml.at_xpath('//dateStamp').text) - Time.current).to be < 60
    end

    specify 'doesn\'t work with empty dataset xml' do
      Project.first.set_complete_dwc_eml_preferences(
        '', '<metadata>\n  <gbif>\n    <dateStamp></dateStamp>\n    <emojiForTheSoul>:D</emojiForTheSoul>  </gbif>\n</metadata>'
      )
      expect{Download::DwcArchive::Complete.create!}
        .to raise_error(ActiveRecord::RecordInvalid, /dataset/)
    end

    specify 'works with empty additional_metadata xml' do
      Project.first.set_complete_dwc_eml_preferences(
        '<alternateIdentifier>ABC123</alternateIdentifier>\n<title xmlns:lang="en">Polka funk</title>', nil
      )
      Download::DwcArchive::Complete.create!
      perform_enqueued_jobs
      eml = Spec::Support::Utilities::Dwca.extract_eml_file(Download.first.file_path)
      expect(eml.at_xpath('//title').text).to eq('Polka funk')
    end

    context 'with predicates data' do
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
        Download::DwcArchive::Complete.create!
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
        project.set_complete_dwc_download_predicates_and_internal_values({
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
        project.set_complete_dwc_download_predicates_and_internal_values({
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

    context 'with media data' do
      let(:project) { Project.first }
      let!(:co) { Specimen.create! }
      let!(:d) { Depiction.create!(depiction_object: co, image: FactoryBot.create(:valid_image)) }
      let!(:c) { Conveyance.create!(conveyance_object: co, sound: FactoryBot.create(:valid_sound)) }

      before(:each) {
        project.update!(set_new_api_access_token: true)
        project.set_complete_dwc_download_extensions(['media'])
      }

      specify 'creates media file rows' do
        perform_enqueued_jobs # create dwc_occurrences
        Download::DwcArchive::Complete.create!

        perform_enqueued_jobs

        tbl = Spec::Support::Utilities::Dwca.extract_media_tsv_table(Download.first.file_path)
        expect(tbl.size).to eq(2) # doesn't include header row
      end

      specify 'fails on images if project_token is gone' do
        # See also project_spec.rb
        perform_enqueued_jobs # create dwc_occurrences
        Download::DwcArchive::Complete.create!

        project.update!(clear_api_access_token: true)

        expect(Download::DwcArchive::Complete.count).to eq(0)
        # TODO: there should/could be another spec here that tests what happens
        # when the project token is cleared *while* image records are being
        # generated - it may be a race between download deletion and the
        # following error, I'm not sure:
        #expect{perform_enqueued_jobs}.to raise_error(TaxonWorks::Error, /project token/)
      end
    end

    context 'with resource relationships data' do
      let(:project) { Project.first }
      let!(:co1) { Specimen.create! }
      let!(:co2) { Specimen.create! }
      let!(:otu) { FactoryBot.create(:valid_otu) } # not represented by a dwc_occurrence data row

      before(:each) {
        project.set_complete_dwc_download_extensions(['resource_relationships'])
      }

      specify 'creates 1 resource relationship row for BA linked to core on one side' do
        project.set_complete_dwc_download_extensions(['resource_relationships'])

        FactoryBot.create(:valid_biological_association, biological_association_subject: co1, biological_association_object: otu)

        Download::DwcArchive::Complete.create!

        perform_enqueued_jobs

        tbl = Spec::Support::Utilities::Dwca.extract_resource_relationships_tsv_table(Download.first.file_path)
        expect(tbl.size).to eq(1) # doesn't include header row
      end

      specify 'creates 2 resource relationship rows for BA linked to core on both sides' do
        project.set_complete_dwc_download_extensions(['resource_relationships'])

        FactoryBot.create(:valid_biological_association, biological_association_subject: co1, biological_association_object: co2)

        Download::DwcArchive::Complete.create!

        perform_enqueued_jobs

        tbl = Spec::Support::Utilities::Dwca.extract_resource_relationships_tsv_table(Download.first.file_path)
        expect(tbl.size).to eq(2) # doesn't include header row
      end
    end
  end
end

