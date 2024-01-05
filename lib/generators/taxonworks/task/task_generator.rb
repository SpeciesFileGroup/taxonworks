# Generate new TaxonWorks tasks
class Generators::TaxonWorks::Task::TaskGenerator < Rails::Generators::Base
  desc 'Used to stub out a TaxonWorks task'

  source_root File.expand_path('../templates', __FILE__)

  argument :controller_base_name, type: 'string', required: true, banner: '<controller_base_name>'
  argument :path_to_controller, type: 'string', required: true, banner: '<"path/to/controller_folder/">'
  argument :methods_actions_names, type: 'array', required: false, banner: '<method_name:action:route_name>'
  class_option :vue, type: :boolean, required: false, default: false

  # This is a Thor task, all methods are invoked in order 

  def check_args
    error_str = ''

    if path_to_controller[0] == '/'
      error_str += "ERROR: 'path_to_controller' can't begin with a '/'\n"
    end

    if path_to_controller[path_to_controller.length - 1] != '/'
      error_str += "ERROR: 'path_to_controller' must end with a '/'\n"
    end

    if error_str.length > 0
      puts Rainbow(error_str).red
      abort
    end

    if options[:vue] && methods_actions_names.present?
      puts Rainbow('--vue is incompatible with method action names, an index is created by default').red
      abort
    end
  end

  def process_args

    @paths = path_to_controller.split('/')
    @route_methods = [] 
    @route_actions = [] 
    @route_names = [] 

    if methods_actions_names.present?
      methods_actions_names.each do |str|
        split_str = str.split(':')
        method = split_str[0]
        action = split_str[1]
        name = split_str[2] || "#{method}_#{controller_base_name}"

        abort(message = "ERROR: malformed method action name\n USAGE: method_name:action_verb:route_name\n") if bad_action_name?(split_str)

        @route_methods.push(method)
        @route_actions.push(action)
        @route_names.push(name + '_task')
      end
    end
  end

  def add_scopes_to_routes
    scopes = ['scope :tasks']
    scope_index = 0

    @paths.each do |path|
      scopes.push("scope :#{path}")
    end

    innermost_scope_str = "scope :#{controller_base_name}, controller: 'tasks/#{path_to_controller}#{controller_base_name}'"

    File.read('config/routes/tasks.rb').split("\n").each do |line|
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

    route_str = ''
    indent_str = '  '

    scopes.each_with_index do |scope, index|
      if index >= scope_index
        route_str += "#{indent_str}#{scope} do\n"
      end

      indent_str += '  '
    end

    route_str += "#{indent_str}#{innermost_scope_str} do\n"

    @route_actions.each_with_index do |action, index|
      route_str += "#{indent_str}  #{action} '#{@route_methods[index]}', as: '#{@route_names[index]}'\n"
    end

    route_str += "#{indent_str}  get :index, as: 'index_#{controller_base_name}_task'\n" if options[:vue]

    route_str += "#{indent_str}end\n"

    scopes.length.downto(scope_index + 1) do
      indent_str.chomp!('  ')
      route_str += "#{indent_str}end\n"
    end

    route_str += "\n"
    insert_into_file('config/routes/tasks.rb', route_str, after: "#{scopes[scope_index - 1]} do\n")
  end



  def add_to_user_task
    user_tasks_str = "\n"

    @route_names.each_with_index do |name, index|
      next if @route_actions[index] != 'get'
      add_user_task(name) 
    end
  end

  def create_controller_folders
    directory_name = 'app/controllers/tasks'

    @paths.each do |path|
      directory_name += "/#{path}"
      Dir.mkdir(directory_name) unless File.directory?(directory_name)
    end
  end

  def create_controller
    template 'controller', "app/controllers/tasks/#{path_to_controller}#{controller_base_name}_controller.rb"
  end

  def create_view_folders
    directory_name = 'app/views/tasks'

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

  def handle_vue
    if options[:vue] 
      create_app
      create_main
      create_vue_index
      register_vue_in_application_js
      add_user_task("index_#{controller_base_name}_task" )
    end
  end

  def instruct_next_steps
    if options[:vue]

      puts "Next steps:"
      puts Rainbow("* Restart your rails development server and confirm the new 'TODO: Task name' card exists and resolves").blue
      puts Rainbow('* Update the generated code throught changing "vue-task" to something specific').blue
    end

  end

  private

  def add_user_task(name)
    user_tasks_str = "\n#{name}:\n"
    user_tasks_str += "  hub: true\n"
    user_tasks_str += "  name: 'TODO: Task name'\n"
    user_tasks_str += "  related:\n"
    user_tasks_str += "  categories:\n"
    user_tasks_str += "  status: prototype\n"
    user_tasks_str += "  description: 'TODO: Task description'\n"
    append_to_file 'config/interface/hub/user_tasks.yml', user_tasks_str
  end

  def create_app
    template 'app', "app/javascript/vue/tasks/#{path_to_controller}#{controller_base_name}/app.vue"
  end

  def create_main
    template 'main', "app/javascript/vue/tasks/#{path_to_controller}#{controller_base_name}/main.js"
  end

  def create_vue_index
    template 'vue_index', "app/views/tasks/#{path_to_controller}#{controller_base_name}/index.html.erb"
  end

  def register_vue_in_application_js
    str =  "require('../vue/tasks/#{path_to_controller}#{controller_base_name}/main.js')" 
    append_to_file 'app/javascript/packs/application.js', str
  end

  def bad_action_name?(array)
    array[0].blank? or array[1].blank?
  end

  def controller_class_name
    controller_base_name.titleize.tr(' ', '')
  end

  def full_controller_class_name
    controller_name = 'Tasks::'
    controller_name += @paths.inject('') do |str, elem|
      str += "#{elem.titleize.tr(' ', '')}::"
    end

    controller_name += controller_class_name
    "#{controller_name.chomp("::")}Controller"
  end

end
