require 'rails_helper'

describe UserTasks do
  let(:task_data) { UserTasks::TASK_DATA }
  let(:tasks) { UserTasks::Tasks }
  let(:prefixes) { Rails.application.routes.named_routes.names }
  let(:referenced_prefixes) { task_data.keys } 

  specify 'TASK_DATA is well formatted' do
    expect(task_data.class).to eq(Hash)
  end

  context 'prefixes in .yml are found as named routes in routes.rb including' do
    UserTasks::TASK_DATA.keys.each do |n|
      specify "#{n}" do
        expect(prefixes.include?(n.to_sym)).to be_truthy, "prefix [#{n}] is not defined in routes.rb"
      end 
    end
  end

  context 'related prefixes in .yml are found as named routes in routes.rb including' do
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


  describe UserTasks::UserTask do
    let (:user_task) { UserTasks::UserTask.new(['foo_name_task', {name: 'do_foo', description: 'A description.', related: ['foo', 'bar']}] ) }

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
    end



    specify '#path' do
      expect(user_task.path).to eq('foo_name_task_path')
    end

    specify '#url' do
      expect(user_task.url).to eq('foo_name_task_url')
    end

    end

end
