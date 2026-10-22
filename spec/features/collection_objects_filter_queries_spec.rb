require 'rails_helper'

# The CO filter task's table request (filter.json with the task's `extend`
# list) must run a fixed number of queries however many rows it returns: a
# per-row query is ~6 queries x 2500 rows at the task's largest page size.
describe 'CollectionObject filter.json queries', type: :feature do
  # As sent by the Filter collection objects task.
  let(:extend_params) {
    %w[dwc_occurrence repository current_repository collecting_event geographic_area_name
       taxon_determinations identifiers container_item container]
  }
  let(:filter_path) {
    '/collection_objects/filter.json?per=50&paginate=true&exclude[]=object_labels&' +
      extend_params.map { |e| "extend[]=#{e}" }.join('&')
  }

  let(:namespace) { FactoryBot.create(:valid_namespace, creator: @user, updater: @user) }
  let(:otu) { factory_bot_create_for_user_and_project(:valid_otu, @user, @project) }
  let(:determiner) { FactoryBot.create(:valid_person, creator: @user, updater: @user) }

  def create_rows(n)
    # Nested records (determiner roles, container items) take housekeeping
    # from Current.
    Current.user_id = @user.id
    Current.project_id = @project.id
    n.times do |i|
      co = factory_bot_create_for_user_and_project(:valid_specimen, @user, @project)
      Identifier::Local::CatalogNumber.create!(
        identifier_object: co, namespace:, identifier: "co#{CollectionObject.count}#{i}",
        creator: @user, updater: @user, project: @project)

      TaxonDetermination.create!(
        taxon_determination_object: co, otu:, determiners: [determiner],
        creator: @user, updater: @user, project: @project)

      container = factory_bot_create_for_user_and_project(:valid_container_box, @user, @project)
      Identifier::Local::ContainerCode.create!(
        identifier_object: container, namespace:, identifier: "box#{Container.count}#{i}",
        creator: @user, updater: @user, project: @project)
      co.put_in_container(container)
    end
  end

  # Database queries for one request, not counting schema lookups or
  # query-cache hits.
  def queries_for(path)
    queries = []
    collect = ->(*, payload) {
      queries << "#{payload[:name]}: #{payload[:sql]}" unless payload[:name] == 'SCHEMA' || payload[:cached]
    }
    ActiveSupport::Notifications.subscribed(collect, 'sql.active_record') { visit path }
    queries
  end

  before { sign_in_user_and_select_project }

  specify 'the query count does not grow with the number of rows' do
    create_rows(2)
    visit filter_path # warm up: first-request lookups
    two = queries_for(filter_path)
    expect(JSON.parse(page.body).size).to eq(2)

    create_rows(3)
    five = queries_for(filter_path)
    rows = JSON.parse(page.body)
    expect(rows.size).to eq(5)
    expect(rows.map { |r| r['taxon_determinations'].first['determiner_roles'].size }).to all(eq(1))
    expect(rows.map { |r| r['container']['identifier'] }).to all(be_present)

    expect(five.size).to eq(two.size), "#{two.size} queries for 2 rows, #{five.size} for 5:\n#{five.join("\n")}"
  end
end
