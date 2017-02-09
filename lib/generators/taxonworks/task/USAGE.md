Description:
    Stubs out the basic needed files for creating a TaxonWorks task

Example:
    rails generate taxonworks:task fasta_load "sequence/" index:get:get_fast_load verify:post:verify_task_name replace:put

    controller_base_name = fasta_load

    path_to_controller = "sequence/"
    
    methods_actions_names = index:get:get_fast_load verify:post:verify_task_name replace:put
        format: method_name:action:route_name
            method_name: 
                verify
            action: 
                get
                put
                post
                patch 
                etc
            route_name OPTIONAL, if none is provided one will be made in the format of method_name + controller_base_name + '_task
                otherwise '_task' will be appended to route_name: 
                task_name
    
    The result of this command will be
        insert  config/routes.rb
        append  config/interface/hub/user_tasks.yml
        create  app/controllers/tasks/sequence/fasta_load_controller.rb
        create  app/views/tasks/sequence/fasta_load/index.html.erb
        create  app/views/tasks/sequence/fasta_load/verify.html.erb
        create  app/views/tasks/sequence/fasta_load/replace.html.erb

        This assumes the "task" scope has already been declared in the routes.rb file.
        Any parent scopes that don't exist for the controller besides the 'task' scope
        will otherwise be procedurally generated. If the scope for the controller already
        exists then the generate will quit. Below is what will be in the following files,
        the view files will be empty.

        insert config/routes.rb:
            scope :sequence do
                scope :fasta_load, controller: 'tasks/sequence/fasta_load' do
                    get 'index', as: 'get_fast_load_task'
                    post 'verify', as: 'verify_task_name_task'
                    put 'replace', as: 'replace_fasta_load_task'
                end
            end

        append  config/interface/hub/user_tasks.yml:
            get_fast_load_task:
                hub: true
                name: 'TODO: Task name'
                related:
                categories:
                status: prototype
                description: 'TODO: Task description'

        create  app/controllers/tasks/sequence/fasta_load_controller.rb:
            class Tasks::Sequence::FastaLoadController < ApplicationController
                include TaskControllerConfiguration

                # GET
                def index
                end

                # POST
                def verify
                end

                # PUT
                def replace
                end

            end
