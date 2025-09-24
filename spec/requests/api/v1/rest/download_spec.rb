require 'rails_helper'

describe 'Api::V1::Downloads', type: :request do
  context 'Download::DwcArchive::Complete' do
    include_context 'api context'

    specify 'complete download must be public to create' do
      get "/api/v1/downloads/dwc_archive_complete?project_token=#{project.api_access_token}"

      expect(response.status).to eq(403)
    end

    context 'complete download is public' do
      before(:each) {
        project.set_complete_dwc_download_is_public(true)
        project.set_complete_dwc_eml_preferences(
          '<alternateIdentifier>ABC123</alternateIdentifier>\n<title xmlns:lang="en">Polka funk</title>',
          '<metadata>\n  <gbif>\n    <dateStamp></dateStamp>\n    <emojiForTheSoul>:D</emojiForTheSoul>  </gbif>\n</metadata>'
        )
      }

      specify 'download fails when no download exists yet' do
        get "/api/v1/downloads/dwc_archive_complete?project_token=#{project.api_access_token}", headers: headers

        expect(response.status).to eq(422)
      end

      specify 'download succeeds after download has been built' do
        # Using this in place of Current/session info so that controllers can
        # create the download when requested.
        allow_any_instance_of(ApplicationController).to receive(:sessions_current_user).and_return(user)
allow_any_instance_of(ApplicationController).to receive(:sessions_current_project_id).and_return(project.id)
        get "/api/v1/downloads/dwc_archive_complete?project_token=#{project.api_access_token}"

        perform_enqueued_jobs

        get "/api/v1/downloads/dwc_archive_complete?project_token=#{project.api_access_token}"

        expect(response.status).to eq(200)
      end

      specify 'pupal download is created when existing is aged out' do
        # Using this in place of Current/session info so that controllers can
        # create the download when requested.
        allow_any_instance_of(ApplicationController).to receive(:sessions_current_user).and_return(user)
allow_any_instance_of(ApplicationController).to receive(:sessions_current_project_id).and_return(project.id)
        get "/api/v1/downloads/dwc_archive_complete?project_token=#{project.api_access_token}"

        perform_enqueued_jobs

        project.set_complete_dwc_download_max_age(0)

        get "/api/v1/downloads/dwc_archive_complete?project_token=#{project.api_access_token}"

        expect(response.status).to eq(200) # the old one is returned
        expect(Download::DwcArchive::PupalComplete.count).to eq(1) # a new one is started
      end

      specify 'pupal download replaces existing when existing is aged out' do
        # Using this in place of Current/session info so that controllers can
        # create the download when requested.
        allow_any_instance_of(ApplicationController).to receive(:sessions_current_user).and_return(user)
allow_any_instance_of(ApplicationController).to receive(:sessions_current_project_id).and_return(project.id)
        get "/api/v1/downloads/dwc_archive_complete?project_token=#{project.api_access_token}"

        perform_enqueued_jobs
        original_id = Download::DwcArchive::Complete.first.id

        project.set_complete_dwc_download_max_age(0)

        get "/api/v1/downloads/dwc_archive_complete?project_token=#{project.api_access_token}"

        perform_enqueued_jobs

        expect(Download::DwcArchive::PupalComplete.count).to eq(0)
        expect(Download::DwcArchive::Complete.count).to eq(1)
        expect(Download::DwcArchive::Complete.first.id).not_to eq(original_id)
      end
    end
  end
end
