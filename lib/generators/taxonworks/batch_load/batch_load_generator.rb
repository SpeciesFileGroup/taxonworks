# Generate new TaxonWorks batch loaders
class Taxonworks::BatchLoadGenerator < Rails::Generators::Base
  desc 'Stub files for a new batch_load for a particular class.'

  source_root File.expand_path("../templates", __FILE__)

  argument :model_name, type: 'string', required: true, banner: '<ModelName>'
  argument :name, type: 'string', required: true, banner: '<batch_loader_name>'

  # when I generate a new batch_load
  #    then I can see that batch_load in the application
  #       and I get warnings for developers to do X
 
  # Fail if existing batch_loader exists 
  def create_interpreter 
    template 'interpreter', "lib/batch_load/import/#{model_path_prefix}/#{name}_interpreter.rb"
  end

  def add_routes
    # To insert rows in order use a template, and pass it to routes
    route_block = ERB.new(File.open(find_in_source_paths('routes.tt')).read)
    route route_block.result(binding) 
  end

  def add_batch_load_index
    f = "app/views/#{model_path_prefix}/batch_load.html.erb"
    create_file f
    index_block = ERB.new(File.open(find_in_source_paths('index.tt')).read)
    append_to_file f, index_block.result(binding)
  end 

  def add_views
    %w{_batch_load _form create preview}.each do |t|
      template "views/#{t}", "app/views/#{model_path_prefix}/batch_load/#{name}/#{t}.html.erb"
    end
  end

  def add_controller_stubs
    f = "app/controllers/#{model_path_prefix}_controller.rb"
    actions_block = ERB.new(File.open(find_in_source_paths('actions.tt')).read)
    inject_into_class f, model_controller, actions_block.result(binding)
  end

  #def generate_data_stub
  #  # batch_load_templates/taxon_names_simple_batch_load.tab
  #end 

  # generate a feature spec to test the generator
  #   that I can get to it

  # dump/show the README to console

  private

  def interpreter_class
    "BatchLoad::Import::#{model_name.pluralize}::#{name.classify}Interpreter"
  end

  def batch_load_name
    name.capitalize.humanize
  end

  def model_path_prefix 
    "#{model_name.tableize}"
  end

  def cookie_name
    batch_load_name + '_' + model_path_prefix + '_md5'
  end

  def model_controller
    "#{model_name}sController"
  end

  def preview_url
    "preview_#{name}_batch_load_#{model_path_prefix}_path"  
  end

  def create_url
    "create_#{name}_batch_load_#{model_path_prefix}"  
  end


end
