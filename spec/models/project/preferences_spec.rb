require 'rails_helper'

describe Project, type: :model, group: [:project] do

  let(:project) { Project.new(name: 'I prefer this project') }

  context 'project.yml' do 
    context 'accessors exist for' do
      Project::BASE_PREFERENCES.keys.each do |k|
        specify "#{k}" do
          expect(project.respond_to?(k)).to be_truthy
        end
      end
    end
  end

  context 'hashed keys' do
    specify '.hash_preferences' do
      expect(Project.hash_preferences).to include(layout: {})
    end

    specify '.array_preferences' do
      expect(Project.array_preferences).to include(default_hub_tab_order: [])
    end

    specify '.key_value_preferences' do
      expect(Project.key_value_preferences).to include(:model_predicate_sets) # etc.
    end
  end

  specify 'filled preferences are not over-written' do
    project.is_api_accessible = true
    project.save!
    expect(project.is_api_accessible).to eq(true)
  end

  specify 'unfilled preferences are filled' do
    project.save!
    expect(project.is_api_accessible).to eq(false)
  end

  specify '#reset_preferences' do
    project.reset_preferences
    expect(project.preferences).to eq(Project::BASE_PREFERENCES)
  end

  context 'with one layout set' do
    before do
      project.layout = { foo: {'firstid' => 1, 'secondid' => 2}}
      project.save!
    end

    specify 'updating another layout' do
      project.layout = {bar: {'second_id' => 1}}
      expect(project.layout.keys).to contain_exactly('foo', 'bar')
    end
  end

  specify '#workbench_starting_path 1' do
    project.save!
    expect(project.workbench_starting_path).to eq('/hub')
  end

  specify '#workbench_starting_path 1' do
    project.workbench_starting_path = '/dashboard' 
    project.save!
    expect(project.workbench_starting_path).to eq('/dashboard')
  end


end
