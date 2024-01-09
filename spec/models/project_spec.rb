require 'rails_helper'

describe Project, type: :model do

  # before(:all) {
  #   Rails.application.eager_load!
  # }

  let(:project) { Project.new }

  let(:user) { User.create!(
    password:  'password',
    password_confirmation: 'password',
    email: 'user_model@example.com',
    name: 'Bob',
    self_created: true
  ) }

  specify 'create 1' do
    expect(Project.create!(name: 'TEST')).to be_truthy
  end

  context 'nil globals' do
    before do
      Current.user_id = nil
      Current.project_id = nil
    end

    after do
      Current.user_id = 1
      Current.project_id = 1
    end

    specify 'create 2' do
      expect(Project.create!(name: 'TEST', by: user)).to be_truthy
    end
  end

  context 'confirm test setup' do
    specify 'one project with id 1 exists from model setup' do
      expect(Project.count).to eq(1)
    end

    specify 'the one project has id 1' do
      expect(Project.first.id).to eq(1)
    end

    specify 'a valid_ factory exists for each has_many association' do
      existing_factories = FactoryBot.factories.map(&:name)
      missing_factories = []
      Project.reflect_on_all_associations(:has_many).each do |r|
        next if r.klass.table_name == 'test_classes'
        factory = "valid_#{r.name.to_s.singularize}".to_sym
        if !existing_factories.include?(factory)
          missing_factories.push factory
        end
      end
      expect(missing_factories.empty?).to be_truthy, "missing #{missing_factories.count} valid_ factories for #{missing_factories.join(", ")}."
    end
  end

  context 'associations' do
    context 'has_many' do
      specify 'project_members' do
        expect(project.project_members << ProjectMember.new).to be_truthy
      end

      specify 'users' do
        expect(project.users << User.new).to be_truthy
      end
    end

    context 'initiated from Rails.application.eager_load!' do
      specify { expect(Project.reflect_on_all_associations(:has_many).size).to be >= 20 }

      specify 'should not include subclasses' do
        expect(Project.reflect_on_all_associations(:has_many).map(&:name).include?(:protonym)).to be_falsey
      end

      specify 'should include superclasses' do
        expect(Project.reflect_on_all_associations(:has_many).map(&:name).include?(:taxon_name)).to be_falsey
      end
    end
  end

  context 'validation' do
    before(:each) do
      project.valid?
    end

    context 'requires' do
      specify '#name' do
        expect(project.errors.include?(:name)).to be_truthy
      end

      specify 'valid with #name' do
        project.name = 'Validation'
        expect(project.valid?).to be_truthy
      end
    end

    context 'name uniqueness' do
      before {
        project.name = 'Foo'
        project.save!
      }

      specify '#name duplicate names are not allowed' do
        p = Project.new(name: 'Foo')
        p.valid?
        expect(p.errors.include?(:name)).to be_truthy
      end
    end
  end

  specify '#set_new_api_access_token 1' do
    project.update!(name: 'Foo', set_new_api_access_token: true)
    expect(project.reload.api_access_token).to be_truthy
  end

  specify '#set_new_api_access_token 2' do
    project.update(name: 'Foo', set_new_api_access_token: '1')
    expect(project.reload.api_access_token).to be_truthy
  end

  specify '#clear_api_access_token 2' do
    project.update!(name: 'Foo', set_new_api_access_token: '1')
    project.update!(clear_api_access_token: true)
    expect(project.reload.api_access_token).to eq(nil)
  end

  context 'root taxon name' do
    before(:each) {
      project.name = 'Root taxon name'
    }

    context 'anything but true creates a name' do
      specify 'on save by default a root taxon name is created' do
        expect(TaxonName.any?).to be_falsey
        project.save!
        expect(project.taxon_names.size).to eq(1)
        expect(project.taxon_names.first.name).to eq('Root')
      end

      specify 'on save by default a root taxon name *is* created when without root taxon name is ""' do
        expect(project.taxon_names.count).to eq(0)
        project.without_root_taxon_name = ''
        project.save!
        expect(project.taxon_names.size).to eq(1)
      end
    end

    specify 'on save by default a root taxon name is not created when without root taxon name is true' do
      project.without_root_taxon_name = true
      project.save!
      expect(project.taxon_names.count).to eq(0)
    end

    specify 'on save by default a root taxon name is not created when without root taxon name is true, on .new()' do
      p = Project.create!(name: 'testing root taxon name', without_root_taxon_name: true)
      expect(p.taxon_names.count).to eq(0)
    end

    context '#root_taxon_name ' do
      let!(:p) { Project.create!(name: 'testing root taxon name', without_root_taxon_name: true) }
      specify 'returns the Root taxon name' do
        expect(p.root_taxon_name).to eq(TaxonName.first)
      end
    end
  end

  context '#destroy sanity test' do
    before(:each) {
      project.update!(name: 'Destroy sanity')

      project.asserted_distributions << AssertedDistribution.new(
        otu:             FactoryBot.create(:valid_otu),
        geographic_area: FactoryBot.create(:valid_geographic_area),
        source:          FactoryBot.create(:valid_source)
      )
      project.save!
    }

    specify { expect(project.asserted_distributions.size).to eq(1) }

    specify "#destroy won't work" do
      expect(AssertedDistribution.count).to eq(1)
      expect(project.destroy).to be_falsey
      expect(AssertedDistribution.count).to eq(1)
    end
  end

  context 'destroying (nuking) a project' do
    let(:u) {FactoryBot.create(:valid_user, email: 'tester@example.com', name: 'Dr. Strangeglove')}
    let(:p) { Project.create!(name: 'a little bit of everything', created_by_id: u.to_param, updated_by_id: u.to_param) }

    after(:all) {
      Current.user_id = 1
      Current.project_id = 1
    }

    before(:each) {
      # Generate 1 of ever valid_ factory
      #    loop through all factories
      #       if a valid_ factory build one setting the project_id to @p.id when present
      Current.project_id = p.id
      Current.user_id = u.id

      @factories_under_test  = {}
      @failed_factories      = {}
      @project_build_err_msg = ''

      exceptions = [:valid_project, :valid_user, :valid_taxon_name]

      FactoryBot.factories.each { |factory|
        f_name = factory.to_s
        next if exceptions.include?(f_name)

        if f_name =~ /^valid_/
          begin
            if factory.build_class.columns.include?(:project)
              test_factory = FactoryBot.build(f_name, project: p)
            else
              test_factory = FactoryBot.build(f_name)
            end
          rescue => detail
            @failed_factories[f_name] = detail
            @project_build_err_msg += "\n\"#{f_name}\" build => #{detail}"
          else
            if test_factory.valid?
              begin
                test_factory.save
              rescue => detail
                @failed_factories[f_name] = detail
                @project_build_err_msg += "\n\"#{f_name}\" save => #{detail}"
              else
                @factories_under_test[f_name] = test_factory
              end
            else
              @failed_factories[f_name] = test_factory.errors
              @project_build_err_msg += "\n\"#{f_name}\" is not valid: #{test_factory.errors.to_a}"
            end
          end

        end
      }

      length = @failed_factories.length
      if length > 0
        @project_build_err_msg += "\n#{length} invalid #{'factory'.pluralize(length)}.\n"
      end
    }

    specify 'project build goes well' do
      expect(@project_build_err_msg.length).to eq(0), @project_build_err_msg
    end

    specify 'MANIFEST is synchronized' do
      actual_project_models = ActiveRecord::Base.connection.tables.map { |x| x.classify.safe_constantize }
        .compact.select { |x| x.has_attribute?(:project_id) }.map(&:to_s)

      diff = (actual_project_models - Project::MANIFEST) + (Project::MANIFEST - actual_project_models)

      next if diff == ['TestClass']

      expect(diff).to be_empty
    end

    context '#nuke' do
      before(:each) {
        p.nuke
      }

      specify '#nuke nukes "everything"' do
        # loop through all the valid_ factories, for each find the class that they build
        #    expect(class_that_was_built.all.reload.count).to eq(0)
        orphans = {}
        project_destroy_err_msg = "Project id should be #{p.id}"
        FactoryBot.factories.each { |factory|
          f_name = factory.name
          if f_name =~ /^valid/
            this_class = factory.build_class
            if this_class.column_names.include?('project_id')
              count = this_class.where(project_id: p.id).all.reload.count
              if count > 0
                project_destroy_err_msg += "\nFactory '#{f_name}': #{this_class}: #{count} orphan #{'record'.pluralize(count)}, remaining project_ids: #{this_class.all.pluck(:project_id).uniq.join(',')}."
                orphans[this_class] = count
              end
            end
          end
        }
        if orphans.length > 0
          project_destroy_err_msg += "\n"
        end
        expect(orphans.length).to eq(0), project_destroy_err_msg
      end

      specify "#nuke doesn't nuke shared data" do
        # loop through shared models (e.g. Serial, Person, Source), ensure that any data that was created remains
        # We may need a constant that stores a *string* representative of the shared classes to loop through,
        #   but for now just enumerate a number of them
        FactoryBot.factories.each { |factory|
          f_name = factory.to_s
          if f_name =~ /^valid_/
            this_class = factory.build_class
            model = this_class.to_s.constantize
            unless model.column_names.include?('project_id')
              expect(model.all.reload.count).to be >= 1
            end
          end
        }
      end
    end
  end

end
