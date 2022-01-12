# Generate new TaxonWorks batch loaders
require 'rails/generators'
class Generators::TaxonWorks::BatchLoad::BatchLoadGenerator < Rails::Generators::Base
  desc 'Stub files for a new batch_load for a particular class.'

  source_root File.expand_path('../templates', __FILE__)

  argument :model_name, type: 'string', required: true, banner: '<ModelName>'
  argument :batch_loader_name, type: 'string', required: true, banner: '<batch_loader_name>'

  # when I generate a new batch_load
  #    then I can see that batch_load in the application
  #       and I get warnings for developers to do X
 
  # Fail if existing batch_loader exists 
  def create_interpreter 
    template 'interpreter', "lib/batch_load/import/#{table_name}/#{batch_loader_name}_interpreter.rb"
  end

  def add_routes
    # To insert rows in order use a template, and pass it to routes
    route_block = ERB.new(File.open(find_in_source_paths('routes.tt')).read)
    prepend_to_file('config/routes/data.rb', route_block.result(binding)) 
    # route route_block.result(binding)  
  end

  def add_batch_load_index
    f = "app/views/#{model_path_prefix}/batch_load.html.erb"
    create_file f
    index_block = ERB.new(File.open(find_in_source_paths('index.tt')).read)
    append_to_file f, index_block.result(binding)
  end 

  def add_views
    %w{_batch_load _form create preview}.each do |t|
      template "views/#{t}", "app/views/#{model_path_prefix}/batch_load/#{batch_loader_name}/#{t}.html.erb"
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
    "#{batch_loader_name.split('_').map(&:capitalize).join('')}Interpreter"
  end

  def full_interpreter_class
    "BatchLoad::Import::#{model_name.pluralize}::#{interpreter_class}"
  end

  def model_path_prefix
    table_name
  end

  def table_name 
    model_name.tableize
  end

  def cookie_name
    "#{batch_loader_name}_batch_load_#{table_name}_md5"
  end

  def model_controller
    "#{model_name.pluralize}Controller"
  end

  def preview_url
    "preview_#{batch_loader_name}_batch_load_#{table_name}_path"  
  end

  def create_url
    "create_#{batch_loader_name}_batch_load_#{table_name}_path"  
  end
end
