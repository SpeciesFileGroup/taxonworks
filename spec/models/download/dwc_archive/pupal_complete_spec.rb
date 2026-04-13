
require 'rails_helper'

RSpec.describe Download::DwcArchive::PupalComplete, type: :model do
  include ActiveJob::TestHelper

  let!(:ce) { FactoryBot.create(:valid_collecting_event) }
  let!(:co) { Specimen.create!(collecting_event: ce) }

  before(:each) {
    # Requires EML without 'STUB's
    Project.first.set_complete_dwc_eml_preferences(
      '<alternateIdentifier>ABC123</alternateIdentifier>\n<title xmlns:lang="en">Polka funk</title>',
      '<metadata>\n  <gbif>\n    <dateStamp></dateStamp>\n    <emojiForTheSoul>:D</emojiForTheSoul>  </gbif>\n</metadata>'
    )
  }

  specify 'only one pupal complete at a time' do
    Download::DwcArchive::PupalComplete.create!
    expect{Download::DwcArchive::PupalComplete.create!}
      .to raise_error(ActiveRecord::RecordInvalid, /Only one.*Pupal/)
  end

  specify 'pupal complete replaces complete when download is ready' do
    complete = Download::DwcArchive::Complete.create!
    perform_enqueued_jobs
    pupal_complete = Download::DwcArchive::PupalComplete.create!
    perform_enqueued_jobs

    expect(Download.find_by(id: complete.id)).to be_falsey
    d = Download::DwcArchive::Complete.first
    expect(d.id).to eq(pupal_complete.id)
    expect(Download::DwcArchive::PupalComplete.count).to eq(0)
  end
end
