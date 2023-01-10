require 'rails_helper'
require 'export/project'

describe Export::Project do

  let(:hierarchy_tables) do
    ActiveRecord::Base.connection.tables.select { |t| t =~ /.*_hierarchies/ }
  end

  let(:known_tables) do
    Export::Project::HIERARCHIES.map(&:first)
  end

  it 'is aware of all hierarchy tables' do
    # If this test breaks because there is a new table be sure to check there is nothing
    # different compared to existing ones before adding it to the list.
    expect(known_tables).to contain_exactly(*hierarchy_tables)
  end

end
