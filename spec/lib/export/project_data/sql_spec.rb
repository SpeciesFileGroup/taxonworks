require 'rails_helper'
require 'export/project_data/sql'

describe Export::ProjectData::Sql do

  let(:hierarchy_tables) do
    ActiveRecord::Base.connection.tables.select { |t| t =~ /.*_hierarchies/ }
  end

  let(:known_tables) do
    Export::ProjectData::HIERARCHIES.map(&:first)
  end

  it 'is aware of all hierarchy tables' do
    # If this test breaks because there is a new table be sure to check there is nothing
    # different compared to existing ones before adding it to the list.
    expect(known_tables).to contain_exactly(*hierarchy_tables)
  end

  context 'user preferences export' do
    let(:user) { FactoryBot.create(:valid_user) }
    let(:project) { FactoryBot.create(:valid_project, by: user) }
    let(:output) { StringIO.new }

    before do
      Current.user_id = user.id
      Current.project_id = project.id
      project.project_members.create!(user: user)
    end

    specify 'exports preferences with double quotes correctly' do
      user.update!(preferences: {
        layout: { 'element"with"quotes' => 1, 'another"one' => 2 },
        disable_chime: false
      })

      Export::ProjectData::Sql.export_users(output, project)
      sql = output.string

      # Verify the SQL contains an INSERT for our user
      expect(sql).to include("INSERT INTO public.users")
      expect(sql).to include(user.id.to_s)

      # Verify the preferences field contains properly escaped JSON
      # With double-encoding: outer JSON escapes inner \" as \\\", producing 3 backslashes + quote
      # In Ruby string literal: need 6 backslashes to represent 3 actual backslashes
      expect(sql).to include('element\\\\\\"with\\\\\\"quotes')
      expect(sql).to include('another\\\\\\"one')
    end

    specify 'exports preferences with single quotes correctly' do
      user.update!(preferences: {
        layout: { "element's_name" => 1, "user's_choice" => 2 },
        disable_chime: true
      })

      Export::ProjectData::Sql.export_users(output, project)
      sql = output.string

      expect(sql).to include("INSERT INTO public.users")
      # Single quotes in PostgreSQL strings are escaped by doubling them
      expect(sql).to include("element''s_name")
      expect(sql).to include("user''s_choice")
    end

    specify 'exports preferences with backslashes correctly' do
      user.update!(preferences: {
        layout: { 'path\\to\\element' => 1, 'escaped\\quote' => 2 }
      })

      Export::ProjectData::Sql.export_users(output, project)
      sql = output.string

      expect(sql).to include("INSERT INTO public.users")
      # With double-encoding: original \\ becomes \\\\ in the SQL output (4 backslashes)
      expect(sql).to include('path\\\\\\\\to\\\\\\\\element')
    end

    specify 'exports complex nested preferences correctly' do
      user.update!(preferences: {
        layout: {
          'panel"one' => { x: 100, y: 200, data: "value's here" },
          'panel\\two' => { x: 300, y: 400, note: 'test"quote' }
        },
        disable_chime: false,
        items_per_list_page: 50
      })

      Export::ProjectData::Sql.export_users(output, project)
      sql = output.string

      expect(sql).to include("INSERT INTO public.users")
      # Verify various special characters are handled correctly
      # With double-encoding: \" becomes \\\" (3 backslashes) and \\ becomes \\\\ (4 backslashes)
      # In Ruby string literals: 6 backslashes for 3, and 8 backslashes for 4
      expect(sql).to include('panel\\\\\\"one')
      expect(sql).to include("value''s here")
      expect(sql).to include('panel\\\\\\\\two')
      expect(sql).to include('test\\\\\\"quote')
      expect(sql).to include('\\"items_per_list_page\\":50')
    end

    specify 'round-trip: exports and reimports preferences with quotes correctly' do
      original_prefs = {
        layout: {
          'element"with"quotes' => 1,
          "element's_name" => 2,
          'path\\to\\element' => 3,
          'complex"mix\'both' => { nested: "value's \"here\"" }
        },
        disable_chime: true,
        items_per_list_page: 50
      }
      user.update!(preferences: original_prefs)

      # Export to SQL
      Export::ProjectData::Sql.export_users(output, project)
      sql_content = output.string

      # Extract the INSERT statement and execute it to test round-trip
      # Change the user ID to avoid conflicts
      new_user_id = User.maximum(:id).to_i + 1000
      modified_sql = sql_content.gsub(/VALUES \(#{user.id},/, "VALUES (#{new_user_id},")

      # Execute the modified SQL - this will fail if JSON escaping is wrong
      expect {
        ActiveRecord::Base.connection.execute(modified_sql)
      }.not_to raise_error

      # Verify the imported preferences actually match the original by loading via ActiveRecord
      # (which handles the double-encoding properly)
      imported_user = User.find(new_user_id)
      prefs = imported_user.preferences

      # Verify all the special characters survived the round-trip
      expect(prefs['layout']['element"with"quotes']).to eq(1)
      expect(prefs['layout']["element's_name"]).to eq(2)
      expect(prefs['layout']['path\\to\\element']).to eq(3)
      expect(prefs['layout']['complex"mix\'both']['nested']).to eq("value's \"here\"")
      expect(prefs['disable_chime']).to eq(true)
      expect(prefs['items_per_list_page']).to eq(50)

      # Clean up
      User.where(id: new_user_id).delete_all
    end
  end

end
