require 'rails_helper'

# See bottom of this file for the Softy class stub.

# SoftValidation extends ActiveRecord.
describe UserTasks do
  let(:tasks) { UserTasks::TASK_DATA }
  let(:task_names) { tasks.keys  }
  let(:paths) { Rails.application.routes.named_routes.names }
  let(:referenced_paths) { task_names.collect{|t| tasks[t][:prefix]}  }

  specify 'TASK_DATA is well formatted' do
    expect(UserTasks::TASK_DATA.class).to eq(Hash)
  end

  context 'all tasks in TASK_DATA have a prefix' do
    UserTasks::TASK_DATA.keys.each do |n|
      specify "#{n}" do
        expect(tasks[n][:prefix]).to be_truthy, "no :prefix: is defined for task named [#{n}]"
      end 
    end
  end

  context 'all prefixes exist as named routes' do
    UserTasks::TASK_DATA.keys.each do |n|
      specify "#{n}" do
        path = tasks[n][:prefix]
        expect(paths.include?(path.to_sym)).to be_truthy, "prefix [#{path}] is not defined in routes.rb"
      end 
    end
  end

  context 'all named tasks with "task" are referenced in user_tasks.yml' do
    Rails.application.routes.named_routes.names.select{|t| t =~ /task/}.each do |name|
      specify "#{name}" do
        expect(referenced_paths.include?(name.to_s)).to be_truthy
      end
    end
  end

  describe UserTasks::UserTask do
    let (:user_task) { UserTasks::UserTask.new(['foo_name_task', {prefix: 'foo_task', description: 'A description.'}] ) }
   
    specify 'tasks have a name' do
      expect(user_task.name).to eq('foo_name_task')
    end

    specify 'tasks have a prefix' do
      expect(user_task.prefix).to eq('foo_task')
    end

    specify 'tasks may have a description' do
      expect(user_task.description).to eq('A description.')
    end
  end

end
