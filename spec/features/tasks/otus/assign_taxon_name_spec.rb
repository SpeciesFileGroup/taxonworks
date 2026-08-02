require 'rails_helper'

describe 'Assign taxon name to OTU task', type: :feature, group: :otu do

  context 'when signed in and a project is selected' do
    before { sign_in_user_and_select_project }

    context 'when I visit the task page' do
      before { visit assign_taxon_name_task_path }

      specify 'page loads without 404' do
        expect(page).to have_content('Assign taxon name to OTU')
      end
    end

    context 'the data endpoint' do
      let(:root) { FactoryBot.create(:root_taxon_name, by: @user, project: @project) }

      let!(:species) do
        genus = Protonym.create!(
          name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: root, by: @user, project: @project
        )
        Protonym.create!(
          name: 'bus', rank_class: Ranks.lookup(:iczn, :species), parent: genus, by: @user, project: @project
        )
      end

      # The task's subject: an OTU named for a taxon name it is not linked to.
      let!(:otu) { Otu.create!(name: 'Aus bus', by: @user, project: @project) }

      # ... and one that is already done, which must not be offered.
      let!(:assigned_otu) { Otu.create!(name: 'Aus bus', taxon_name: species, by: @user, project: @project) }

      let(:result) { JSON.parse(page.body) }

      before { visit assign_taxon_name_task_data_path(format: :json) }

      specify 'returns only OTUs without a taxon name' do
        expect(result.map { |r| r['otu']['id'] }).to contain_exactly(otu.id)
      end

      specify 'matches the OTU name against nomenclature' do
        expect(result.first['candidates'].map { |c| c['id'] }).to eq([species.id])
      end

      specify 'reports the string that was matched' do
        expect(result.first['match_string']).to eq('Aus bus')
      end
    end

    # A full page of curator-refined match strings does not fit in a request URI, which is
    # what made "keep first word only" over a whole selected page fail with a 400.
    context 'with a match string for every row on a page' do
      let!(:otus) do
        200.times.map { |i| Otu.create!(name: "Aus bus#{i}", by: @user, project: @project) }
      end

      let(:match_strings) { otus.to_h { |o| [o.id.to_s, 'Aus'] } }

      # The browser client sends this via ajaxCall; page.driver.post does not.
      def post_data
        visit assign_taxon_name_task_path
        token = page.find('meta[name="csrf-token"]', visible: false)[:content]

        page.driver.post(
          assign_taxon_name_task_data_path(format: :json),
          { match_strings: },
          { 'HTTP_X_CSRF_TOKEN' => token }
        )
      end

      specify 'the data endpoint accepts them over POST' do
        post_data
        expect(page.driver.response.status).to eq(200)
      end

      specify 'and matches on them rather than the OTU names' do
        post_data
        expect(JSON.parse(page.driver.response.body).map { |r| r['match_string'] }.uniq).to eq(['Aus'])
      end
    end

    # The scopes arrive as request params, not as the Hashes the library spec passes.
    context 'when handed scoping queries' do
      let(:root) { FactoryBot.create(:root_taxon_name, by: @user, project: @project) }

      let(:genus) do
        Protonym.create!(
          name: 'Aus', rank_class: Ranks.lookup(:iczn, :genus), parent: root, by: @user, project: @project
        )
      end

      let!(:species) do
        Protonym.create!(
          name: 'bus', rank_class: Ranks.lookup(:iczn, :species), parent: genus, by: @user, project: @project
        )
      end

      let!(:other_genus) do
        Protonym.create!(
          name: 'Xus', rank_class: Ranks.lookup(:iczn, :genus), parent: root, by: @user, project: @project
        )
      end

      let!(:otu) { Otu.create!(name: 'Aus bus', by: @user, project: @project) }
      let!(:other_otu) { Otu.create!(name: 'Zus zus', by: @user, project: @project) }

      let(:result) { JSON.parse(page.body) }

      specify 'an otu_query narrows the OTUs listed' do
        visit assign_taxon_name_task_data_path(
          format: :json, otu_query: { name: 'Zus', name_exact: false }
        )

        expect(result.map { |r| r['otu']['id'] }).to contain_exactly(other_otu.id)
      end

      specify 'a taxon_name_query narrows the candidate pool' do
        visit assign_taxon_name_task_data_path(
          format: :json, taxon_name_query: { taxon_name_id: [other_genus.id], descendants: true }
        )

        row = result.find { |r| r['otu']['id'] == otu.id }
        expect(row['candidates']).to be_empty
      end

      specify 'without a taxon_name_query the candidate is found' do
        visit assign_taxon_name_task_data_path(format: :json)

        row = result.find { |r| r['otu']['id'] == otu.id }
        expect(row['candidates'].map { |c| c['id'] }).to eq([species.id])
      end
    end
  end

end
