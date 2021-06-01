require 'rspec'
require 'rails_helper'

# These linting specs should always be run 
describe TaxonWorks, group: :lint do
  # Since Rails doesn't load classes unless it needs them, so you must eager load them to get all the models.

  let(:route_names) { Rails.application.routes.routes.map(&:name).compact }  

  context 'route cross references' do

    Rails.application.eager_load!

    specify 'object_radials.yml route references exist in routes/tasks.rb' do
      fail = false 

      OBJECT_RADIALS.keys.collect{|k| OBJECT_RADIALS[k]["tasks"]}.flatten.uniq.each do |t|
        if !route_names.include?(t)
          puts Rainbow(t + ' not found routes/tasks.rb').red
          fail = true
        end
      end

      expect(fail).to be_falsey
    end

    specify 'config/interface/hub/user_tasks.yml named routes exists in routes/tasks.rb' do
      fail = false 

      UserTasks::TASK_DATA.keys.each do |t|
        if !route_names.include?(t)
          puts Rainbow(t + ' not found routes/tasks.rb').red
          fail = true
        end
      end

      expect(fail).to be_falsey
    end
  end
end

