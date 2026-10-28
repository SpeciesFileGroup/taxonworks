require 'rails_helper'

# The CE filter task's table request (filter.json with the task's `extend`
# list) must run a fixed number of queries however many rows it returns.
describe 'CollectingEvent filter.json queries', type: :feature do
  # As sent by the Filter collecting events task (plus the full geographic_area).
  let(:filter_path) {
    '/collecting_events/filter.json?per=50&exclude[]=object_labels&extend[]=roles&extend[]=geographic_area_name&extend[]=geographic_area'
  }

  let(:namespace) { FactoryBot.create(:valid_namespace, creator: @user, updater: @user) }
  let(:geographic_area) { FactoryBot.create(:valid_geographic_area) }

  def create_rows(n)
    Current.user_id = @user.id
    Current.project_id = @project.id
    n.times do |i|
      ce = factory_bot_create_for_user_and_project(:valid_collecting_event, @user, @project)
      ce.update!(geographic_area:)
      Identifier::Local::FieldNumber.create!(
        identifier_object: ce, namespace:, identifier: "ce#{CollectingEvent.count}#{i}",
        creator: @user, updater: @user, project: @project)
      Collector.create!(
        role_object: ce, person: FactoryBot.create(:valid_person, creator: @user, updater: @user),
        creator: @user, updater: @user, project: @project)
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
    expect(rows.map { |r| r['identifiers'].size }).to all(eq(1))
    expect(rows.map { |r| r['collector_roles'].size }).to all(eq(1))
    expect(rows.map { |r| r['geographic_area_name'] }).to all(be_present)

    expect(five.size).to eq(two.size), "#{two.size} queries for 2 rows, #{five.size} for 5:\n#{five.join("\n")}"
  end
end
