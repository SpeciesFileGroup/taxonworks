# Generate new TaxonWorks tasks
class Taxonworks::TaskGenerator < Rails::Generators::Base
  desc 'Used to stub out a TaxonWorks task'

  source_root File.expand_path('../templates', __FILE__)

  argument :controller_base_name, type: 'string', required: true, banner: '<controller_base_name>'
  argument :path_to_controller, type: 'string', required: true, banner: '<"path/to/controller_folder/">'
  argument :methods_actions_names, type: 'array', required: true, banner: '<method_name:action:route_name>'

  def check_args
    error_str = ""

    if path_to_controller[0] == "/"
      error_str += "ERROR: 'path_to_controller' can't begin with a '/'\n"
    end

    if path_to_controller[path_to_controller.length - 1] != "/"
      error_str += "ERROR: 'path_to_controller' must end with a '/'\n"
    end

    if error_str.length > 0
      puts error_str
      abort
    end
  end

  def process_args
    @paths = path_to_controller.split("/")
    @route_methods = Array.new
    @route_actions = Array.new
    @route_names = Array.new

    methods_actions_names.each do |str|
        split_str = str.split(":")
        method = split_str[0]
        action = split_str[1]
        name = split_str[2] || "#{method}_#{controller_base_name}"

        @route_methods.push(method)
        @route_actions.push(action)
        @route_names.push(name + "_task")
    end
  end

  def add_scopes_to_routes
    scopes = ["scope :tasks"]
    scope_index = 0

    @paths.each do |path|
      scopes.push("scope :#{path}")
    end

    innermost_scope_str = "scope :#{controller_base_name}, controller: 'tasks/#{path_to_controller}#{controller_base_name}'"

    File.read("config/routes.rb").split("\n").each do |line|
      if line.include?(innermost_scope_str)
        puts "ERROR: \"#{innermost_scope_str}\" already exists!"
        abort
      elsif scope_index < scopes.length && line.include?(scopes[scope_index])
        scope_index += 1
      end
    end

    if scope_index == 0
      puts "ERROR: Couldn't find 'task' scope!"
      abort
    end

    route_str = ""
    indent_str = "  "

    scopes.each_with_index do |scope, index|
      if index >= scope_index
        route_str += "#{indent_str}#{scope} do\n" 
      end

      indent_str += "  "
    end

    route_str += "#{indent_str}#{innermost_scope_str} do\n"
    
    @route_actions.each_with_index do |action, index|
      route_str += "#{indent_str}  #{action} '#{@route_methods[index]}', as: '#{@route_names[index]}'\n"
    end

    route_str += "#{indent_str}end\n"

    scopes.length.downto(scope_index + 1) do
      indent_str.chomp!("  ")
      route_str += "#{indent_str}end\n"
    end

    route_str += "\n"
    insert_into_file("config/routes.rb", route_str, after: "#{scopes[scope_index - 1]} do\n")
  end

  def add_to_user_task
    user_tasks_str = "\n"

    @route_names.each_with_index do |name, index|
      next if @route_actions[index] != "get"
      
      user_tasks_str += "#{name}:\n"
      user_tasks_str += "  hub: true\n"
      user_tasks_str += "  name: 'TODO: Task name'\n"
      user_tasks_str += "  related:\n"
      user_tasks_str += "  categories:\n"
      user_tasks_str += "  status: prototype\n"
      user_tasks_str += "  description: 'TODO: Task description'\n"
    end

    append_to_file "config/interface/hub/user_tasks.yml", user_tasks_str
  end

  def create_controller_folders
    directory_name = "app/controllers/tasks"

    @paths.each do |path|
      directory_name += "/#{path}"
      Dir.mkdir(directory_name) unless File.directory?(directory_name)
    end
  end

  def create_controller
    template "controller", "app/controllers/tasks/#{path_to_controller}#{controller_base_name}_controller.rb"
  end

  def create_view_folders
    directory_name = "app/views/tasks"

    @paths.each do |path|
      directory_name += "/#{path}"
      Dir.mkdir(directory_name) unless File.directory?(directory_name)
    end

    Dir.mkdir(directory_name += "/#{controller_base_name}") unless File.directory?(directory_name)
  end

  def create_views
    @route_methods.each do |method|
      create_file "app/views/tasks/#{path_to_controller}#{controller_base_name}/#{method}.html.erb"
    end
  end

  private
  
  def controller_class_name
    controller_base_name.titleize.tr(' ', '')
  end

  def full_controller_class_name
    controller_name = "Tasks::"
    controller_name += @paths.inject("") do |str, elem|
      str += "#{elem.titleize.tr(' ', '')}::" 
    end

    controller_name += controller_class_name
    "#{controller_name.chomp("::")}Controller"
  end

end 
