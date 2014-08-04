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

    before(:all) {
      @p                    = Project.create(name: 'a little bit of everything')
      $project_id           = @p.id
      $user_id              = 1

      # Generate 1 of ever valid_ factory
      #    loop through all factories
      #       if a valid_ factory build one setting the project_id to @p.id when present

      @factories_under_test = {}
      @failed_factories     = {}
      @project_build_err_msg = ''
      FactoryGirl.factories.each { |factory|
        f_name = factory.name
        if f_name =~ /^valid_/
#          next if f_name.to_s == 'valid_biological_relationship_type'
          next if f_name.to_s == 'valid_taxon_name'
          begin
            if factory.definition.attributes.names.include?(:project_id)
              test_factory = FactoryGirl.build(f_name, project_id: @p.id)
            else
              test_factory = FactoryGirl.build(f_name)
            end
          rescue => detail
            @failed_factories[f_name] = detail
            @project_build_err_msg += "\n\"#{f_name}\" build => #{detail}"
          else
            unless test_factory.attributes['project_id'].nil?
              test_factory.project = @p
            end
            if f_name == :valid_taxon_name
              test_factory.parent.project_id = @p.id
            end
            if test_factory.valid?
              begin
                test_factory.save
              rescue => detail
                @failed_factories[f_name] = detail
                @project_build_err_msg +=  "\n\"#{f_name}\" save => #{detail}"
              else
                @factories_under_test[f_name] = test_factory
              end
            else
              @failed_factories[f_name] = test_factory.errors
              @project_build_err_msg +=  "\n\"#{f_name}\" is not valid: #{test_factory.errors.to_a}"
            end
          end
        end
      }
      length = @failed_factories.length
      if length > 0
        @project_build_err_msg +=  "\n#{length} invalid #{'factory'.pluralize(length)}.\n"
      end
    }

    after(:all) {
      FactoryGirl.factories.each { |factory|
        f_name = factory.name
        if f_name =~ /^valid_/
          this_class = factory.build_class.to_s
          model      = this_class.constantize
          case this_class
            when 'User', 'Project'
              # todo: figure out how to delete all with id greater than 1
            else
              model.delete_all
          end
        end
      }
    }

    specify 'project build goes well' do
      expect(@project_build_err_msg.length).to eq(0), @project_build_err_msg
    end

    specify '#destroy' do
      expect(@p.destroy).to be_truthy # confirm this is a really what we want
      expect(@p.destroyed?).to be(true)
    end

    context '#destroy' do
      before(:all) {
        @p.destroy
      }

      specify '#destroy nukes "everything"' do
        # loop through all the valid_ factories, for each find the class that they build
        #    expect(class_that_was_built.all.reload.count).to eq(0)
        orphans = {}
        project_destroy_err_msg = ''
        FactoryGirl.factories.each { |factory|
          f_name = factory.name
          if f_name =~ /^valid/
            this_class = factory.build_class
            model      = this_class.to_s.constantize
            if model.column_names.include?('project_id')
              count = model.all.reload.count
              if count > 0
                project_destroy_err_msg += "\nFactory '#{f_name}': #{this_class.to_s}: #{count} orphan #{'record'.pluralize(count)}."
                orphans[model] = count
              end
            end
          end
        }
        if orphans.length > 0
          project_destroy_err_msg += "\n"
        end
        expect(orphans.length).to eq(0), project_destroy_err_msg
      end

      specify "#destroy doesn't nuke shared data" do
        # loop through shared models (e.g. Serial, Person, Source), ensure that any data that was created remains
        # We may need a constant that stores a *string* representative of the shared classes to loop through,
        #   but for now just enumerate a number of them
        FactoryGirl.factories.each { |factory|
          f_name = factory.name
          if f_name =~ /^valid_/
            this_class = factory.build_class
            model      = this_class.to_s.constantize
            unless model.column_names.include?('project_id')
              expect(model.all.reload.count).to be >= 1
            end
          end
        }
      end
    end

  end

end
