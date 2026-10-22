require 'rails_helper'

# The FO filter task's table request (filter.json with the task's `extend`
# list) must run a fixed number of queries however many rows it returns.
# See also collection_objects_filter_queries_spec.rb.
describe 'FieldOccurrence filter.json queries', type: :feature do
  # As sent by the Filter field occurrences task.
  let(:extend_params) {
    %w[collecting_event geographic_area_name taxon_determinations identifiers dwc_occurrence]
  }
  let(:filter_path) {
    '/field_occurrences/filter.json?per=50&paginate=true&exclude[]=object_labels&' +
      extend_params.map { |e| "extend[]=#{e}" }.join('&')
  }

  let(:namespace) { FactoryBot.create(:valid_namespace, creator: @user, updater: @user) }
  let(:determiner) { FactoryBot.create(:valid_person, creator: @user, updater: @user) }

  def create_rows(n)
    # Nested records (the factory's determination and otu, determiner roles)
    # take housekeeping from Current.
    Current.user_id = @user.id
    Current.project_id = @project.id
    n.times do |i|
      fo = factory_bot_create_for_user_and_project(:valid_field_occurrence, @user, @project)
      Identifier::Local::CatalogNumber.create!(
        identifier_object: fo, namespace:, identifier: "fo#{FieldOccurrence.count}#{i}",
        creator: @user, updater: @user, project: @project)
      Identifier::Local::FieldNumber.create!(
        identifier_object: fo.collecting_event, namespace:, identifier: "ce#{CollectingEvent.count}#{i}",
        creator: @user, updater: @user, project: @project)
      Determiner.create!(role_object: fo.taxon_determinations.first, person: determiner)
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
    expect(rows.map { |r| r['collecting_event']['identifiers'].size }).to all(eq(1))

    expect(five.size).to eq(two.size), "#{two.size} queries for 2 rows, #{five.size} for 5:\n#{five.join("\n")}"
  end
end
