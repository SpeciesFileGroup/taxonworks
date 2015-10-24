require 'rails_helper'

describe UserTasks do
  let(:task_data) { UserTasks::TASK_DATA }
  let(:prefixes) { Rails.application.routes.named_routes.names }

  specify 'TASK_DATA is well formatted' do
    expect(task_data.class).to eq(Hash)
  end

  context 'prefixes in user_tasks.yml are found as named routes in routes.rb including' do
    UserTasks::TASK_DATA.keys.each do |n|
      specify "#{n}" do
        expect(prefixes.include?(n.to_sym)).to be_truthy, "prefix [#{n}] is not defined in routes.rb"
      end 
    end
  end

  context 'related prefixes in user_task.yml are found as named routes in routes.rb including' do
    UserTasks::TASK_DATA.each do |key, attributes|
      if attributes['related'] 
        attributes['related'].each do |n|
          specify "#{n}" do
            expect(prefixes.include?(n.to_sym)).to be_truthy, "related prefix [#{n}] is not defined in routes.rb"
          end 
        end
      end
    end
  end

  context 'hub: true tasks can not require parameters' do
    UserTasks.hub_tasks.each do |task|
      specify "#{task.prefix} is parameters free" do
        expect(task.requires_params?).to eq(false), "#{task.prefix} requires parameters, it is not allowed on the hub list"
      end 
    end
  end

  context 'all prefixes in user_tasks.yml end in "_task"' do
    UserTasks::TASK_DATA.each do |t|
      specify "#{t[0]}" do
        expect(t[0] =~ /_task\Z/).to be_truthy, "#{t[0]} does not end in '_task'"
      end
    end
  end

  specify '.tasks' do
    expect(UserTasks.tasks).to eq(UserTasks::INDEXED_TASKS.values)
  end

  specify '.task(prefix)' do
    expect(UserTasks.task('build_biocuration_groups_task').class).to eq(UserTasks::UserTask)
  end


  describe UserTasks::UserTask do
    let (:user_task) { UserTasks::UserTask.new(
      ['foo_name_task', 
       {
        'name' => 'do_foo', 
        'description' => 'A description.', 
        'related' => ['foo', 'bar'],
        'hub' => true
      }])}

    context 'has attributes' do 
      specify '#name' do
        expect(user_task.name).to eq('do_foo')
      end

      specify '#prefix' do
        expect(user_task.prefix).to eq('foo_name_task')
      end

      specify '#description' do
        expect(user_task.description).to eq('A description.')
      end

      specify '#related' do
        expect(user_task.related).to eq(['foo', 'bar'])
      end

      specify '#hub' do
        expect(user_task.hub).to eq(true) 
      end



    end

    specify '#path' do
      expect(user_task.path).to eq('foo_name_task_path')
    end

    specify '#url' do
      expect(user_task.url).to eq('foo_name_task_url')
    end

    # A (brittle) proxy test, since our UserTasks::UserTask instance isn't a registered application route.
    specify '#requires_params?' do
      expect( Rails.application.routes.named_routes.get('quick_verbatim_material_task').required_keys.sort).to eq([:action, :controller])
      expect( Rails.application.routes.named_routes.get('user_activity_report_task').required_keys.sort).to_not eq([:action, :controller])
    end
  end

end
