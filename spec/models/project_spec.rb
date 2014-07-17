require 'rails_helper'

# Projects are extended by various related concerns.  When 
# we get to testing them we will have to do this here:
#   Rails.application.eager_load!

describe Project, :type => :model do

  let(:project) { FactoryGirl.build(:project) }

  context 'associations' do
    context 'has_many' do
      specify 'project_members' do
        expect(project.project_members << ProjectMember.new).to be_truthy
      end

      specify 'users' do
        expect(project.users << User.new).to be_truthy
      end
    end
  end

  context 'workbench_settings' do
    before(:each) {
      project.name = 'My Project'
      project.save!
    }
    specify 'are set to default' do
      expect(project.workbench_settings).to eq(Project::DEFAULT_WORKBENCH_SETTINGS)
    end

    specify 'can be cleared with #clear_workbench_settings' do
      expect(project.clear_workbench_settings).to be_truthy
      expect(project.workbench_settings).to eq(Project::DEFAULT_WORKBENCH_SETTINGS)
    end

    specify 'default_path defaults to DEFAULT_WORKBENCH_STARTING_PATH' do
      expect(project.workbench_starting_path).to eq(Project::DEFAULT_WORKBENCH_STARTING_PATH)
      expect(project.workbench_settings['workbench_starting_path']).to eq(Project::DEFAULT_WORKBENCH_STARTING_PATH)
    end

    specify 'updating an attribute is a little tricky, use _will_change!' do
      expect(project.workbench_starting_path).to eq(Project::DEFAULT_WORKBENCH_STARTING_PATH)
      expect(project.workbench_settings_will_change!).to eq({"workbench_starting_path" => "/hub"}) # was changed from nil
      expect(project.workbench_settings['workbench_starting_path'] = '/dashboard').to be_truthy
      expect(project.save!).to be_truthy
      project.reload
      expect(project.workbench_starting_path).to eq('/dashboard')
    end

  end

  context 'validation' do
    before(:each) do
      project.valid?
    end

    context 'requires' do
      specify 'name' do
        expect(project.errors.include?(:name)).to be_truthy
      end

      specify 'valid with name' do
        project.name = 'Project!'
        expect(project.valid?).to be_truthy
      end
    end
  end

  context 'destroy' do

    before {
      @p                    = Project.create(name: 'a little bit of everything')
      @project_id           = @p.id
      @user_id              = User.where(id: 1)

      # Generate 1 of ever valid_ factory
      #    loop through all factories
      #       if a valid_ factory build one setting the project_id to @p.id when present

      @factories_under_test = {}
      @failed_factories     = {}
      FactoryGirl.factories.each { |factory|
        if factory.name =~ /^valid_/
          begin
            test_factory = FactoryGirl.build(factory.name)
          rescue => detail
            @failed_factories[factory.name] = detail
            puts "\"#{factory.name}\" build #{detail}"
          else
            if test_factory.valid?
              test_factory.save
              @factories_under_test[factory.name] = test_factory
            else
              @failed_factories[factory.name] = test_factory.errors
              puts "\"#{factory.name}\" is not valid: #{test_factory.errors.to_a}"
            end
          end
        end
      }
    }


    specify '#destroy' do
      expect(@p.destroy).to be_truthy # confirm this is a really what we want
      expect(@p.destroyed?).to be(true)
    end

    context '#destroy' do
      before {
        @p.destroy
      }

      skip '#destroy nukes "everything"' do
        # loop through all the valid_ factories, for each find the class that they build
        #    expect(class_that_was_built.all.reload.count).to eq(0) 
      end

      skip "#destroy doesn't nuke shared data" do
        # loop through shared models (e.g. Serial, Person, Source), ensure that any data that was created remains
        # We may need a constant that stores a *string* representative of the shared classes to loop through, but for now just enumerate a number of them
      end
    end

  end

end
