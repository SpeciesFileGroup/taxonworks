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

  context 'Download::Coldp::Complete' do
    include_context 'api context'

    let(:otu) { Otu.create!(name: 'root', by: user, project:) }
    let(:other_otu) { Otu.create!(name: 'other', by: user, project:) }

    def make_profile(otu_id:, is_public:, max_age: nil, default_user_id: nil)
      project.create_coldp_profile(
        'otu_id' => otu_id,
        'is_public' => is_public,
        'max_age' => max_age,
        'default_user_id' => default_user_id
      )
    end

    specify 'otu_id is required' do
      get "/api/v1/downloads/coldp_complete?project_token=#{project.api_access_token}"

      expect(response.status).to eq(422)
      expect(JSON.parse(response.body)['error']).to match(/otu_id/)
    end

    specify 'download is forbidden when no profile exists for the otu' do
      get "/api/v1/downloads/coldp_complete?project_token=#{project.api_access_token}&otu_id=#{otu.id}"

      expect(response.status).to eq(403)
    end

    specify 'download is forbidden when the profile is not public' do
      make_profile(otu_id: otu.id, is_public: false)

      get "/api/v1/downloads/coldp_complete?project_token=#{project.api_access_token}&otu_id=#{otu.id}"

      expect(response.status).to eq(403)
    end

    specify 'download is forbidden when the requested otu differs from a public profile' do
      make_profile(otu_id: otu.id, is_public: true)

      get "/api/v1/downloads/coldp_complete?project_token=#{project.api_access_token}&otu_id=#{other_otu.id}"

      expect(response.status).to eq(403)
    end

    context 'profile is public' do
      before { make_profile(otu_id: otu.id, is_public: true, default_user_id: user.id) }

      specify 'first request enqueues a build and reports it is being created' do
        get "/api/v1/downloads/coldp_complete?project_token=#{project.api_access_token}&otu_id=#{otu.id}"

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['status']).to eq('A download is being created')
        expect(Download::Coldp::Complete.where(project: project, request: otu.id.to_s).count).to eq(1)
      end

      specify 'second in-flight request does not create a duplicate Complete row' do
        get "/api/v1/downloads/coldp_complete?project_token=#{project.api_access_token}&otu_id=#{otu.id}"

        get "/api/v1/downloads/coldp_complete?project_token=#{project.api_access_token}&otu_id=#{otu.id}"

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)['status']).to eq('The existing download is not ready yet')
        expect(Download::Coldp::Complete.where(project: project, request: otu.id.to_s).count).to eq(1)
      end

      specify 'Complete rows for different otus do not collide' do
        make_profile(otu_id: other_otu.id, is_public: true, default_user_id: user.id)

        get "/api/v1/downloads/coldp_complete?project_token=#{project.api_access_token}&otu_id=#{otu.id}"
        get "/api/v1/downloads/coldp_complete?project_token=#{project.api_access_token}&otu_id=#{other_otu.id}"

        expect(Download::Coldp::Complete.where(project: project).pluck(:request)).to contain_exactly(otu.id.to_s, other_otu.id.to_s)
      end

      specify 'download uses the profile default_user_id when no session user is present' do
        get "/api/v1/downloads/coldp_complete?project_token=#{project.api_access_token}&otu_id=#{otu.id}"

        download = Download::Coldp::Complete.find_by!(project: project, request: otu.id.to_s)
        expect(download.created_by_id).to eq(user.id)
      end

      specify 'pupal download starts when the existing complete is past max_age' do
        # Bypass the async build so the existing Complete is marked ready without
        # running the CoLDP exporter (covered end-to-end in spec/lib/export/coldp_spec.rb).
        allow_any_instance_of(Download::Coldp::Complete).to receive(:ready?).and_return(true)
        existing = Download::Coldp::Complete.create!(by: user.id, project: project, request: otu.id.to_s)

        project.update_coldp_profile('otu_id' => otu.id, 'is_public' => true, 'max_age' => 0, 'default_user_id' => user.id)

        get "/api/v1/downloads/coldp_complete?project_token=#{project.api_access_token}&otu_id=#{otu.id}"

        expect(Download::Coldp::PupalComplete.where(project: project, request: otu.id.to_s).count).to eq(1)
      end
    end
  end
end
